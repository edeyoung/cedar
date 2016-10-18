require 'rails_helper'
require 'fileutils'
require 'nokogiri'
require 'rspec/expectations'
# Unit test cases for all of the Cedar invalidators
RSpec.describe 'Invalidator Tests: ' do
  include RSpec::Matchers

  # include Mongoid::Document
  # before :all do
  #   setup_fixture_data
  # end

  before(:each) do
    @cat_1_file = IO.read('test/fixtures/qrda/cat_1/good.xml')
    @cat_3_file = IO.read('test/fixtures/qrda/cat_3/good.xml')
    setup_fixture_data
  end

  # --- Validations for both QRDA Category 1 and Category 3 ---
  it 'test_inconsistent_time_formats' do
    expect(@cat_1_file).to_not be_nil
    bad_file = Nokogiri::XML(Cedar::Invalidator.inconsistent_time_formats(Nokogiri::XML(@cat_1_file)))
    all_times = bad_file.css('effectiveTime low[value], effectiveTime high[value], effectiveTime [value]').to_a
    invalid_times = 0
    all_times.each { |time| invalid_times += 1 if time.attributes['value'].value.length > 14 }
    expect(invalid_times).to eq(1)
  end

  it 'test_invalid_measure_id' do
    # Find all the valid measure ids
    valid_measure_ids = []

    HealthDataStandards::CQM::Measure.all.to_a.each do |measure|
      expect(measure.id.nil?).to_not be_empty
      # puts 'measure: ' + measure
      valid_measure_ids.push(measure.hqmf_id)
      valid_measure_ids.push(measure.hqmf_set_id)
    end

    expect(valid_measure_ids).to_not be_empty
    # Test the measure IDs to see if they are valid
    bad_file = Nokogiri::XML(Cedar::Invalidator.invalid_measure_id(Nokogiri::XML(@cat_1_file)))
    measure_id = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.98"] ~ reference externalDocument id').attributes['extension'].value
    set_id = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.98"] ~ reference externalDocument setId').attributes['root'].value
    expect(valid_measure_ids.include?(measure_id)).to be true
    expect(valid_measure_ids.include?(set_id)).to be true
  end

  it 'test_reporting_period' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.reporting_period(Nokogiri::XML(@cat_1_file)))
    period_start = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.17.3.8"] ~ effectiveTime low').attributes['value'].value.to_i
    period_end = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.17.3.8"] ~ effectiveTime high').attributes['value'].value.to_i
    # TODO: Find out the valid reporting periods from the uploaded bundle files and use that instead
    expect(period_start > 20_300_101_000_000 && period_end > 20_300_101_000_000).to be true
  end

  it 'test_unfinished_file' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.unfinished_file(@cat_3_file))
    expect(bad_file.errors.length > 1).to be true
  end

  # --- Validations for QRDA Category 3 ---
  it 'test_denom_greater_than_ipp' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.denom_greater_than_ipp(Nokogiri::XML(@cat_3_file)))
    ipp_value = get_population_value(bad_file, 'IPP')
    denom_value = get_population_value(bad_file, 'DENOM')
    expect(denom_value >= ipp_value).to be true
  end

  it 'test_duplicate_population_ids' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.duplicate_population_ids(Nokogiri::XML(@cat_3_file)))
    # Find a random population in the file to duplicate
    all_populations_search = ''
    (CV_POPULATION_KEYS + PROPORTION_POPULATION_KEYS).uniq.each do |id|
      all_populations_search += 'value[code="' + id + '"] ~ reference externalObservation id[root], '
    end
    population_ids = bad_file.css(all_populations_search.chomp(', ')).to_a.map { |pop| pop.attributes['root'].value }
    expect(population_ids.count - population_ids.uniq.count == 1).to be true
  end

  it 'test_missing_population_id' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.missing_population_id(Nokogiri::XML(@cat_3_file)))
    required_population_keys = REQUIRED_PROPORTION_POPULATION_KEYS
    required_populations_search = ''
    required_population_keys.uniq.each { |id| required_populations_search += 'value[code="' + id + '"], ' }
    required_populations = bad_file.css(required_populations_search.chomp(', ')).to_a
    expect(required_populations.length < required_population_keys.length).to be true
  end

  it 'test_numer_greater_than_denom' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.numer_greater_than_denom(Nokogiri::XML(@cat_3_file)))
    numer_value = get_population_value(bad_file, 'NUMER')
    denom_value = get_population_value(bad_file, 'DENOM')
    expect(numer_value >= denom_value).to be true
  end

  it 'test_performance_rate_divide_by_zero' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.performance_rate_divide_by_zero(Nokogiri::XML(@cat_3_file)))
    performance_rate_value = bad_file.at_css('code[code="72510-1"][codeSystem="2.16.840.1.113883.6.1"] ~ value').attributes['value'].value
    denom_value = get_population_value(bad_file, 'DENOM')
    denex_value = get_population_value(bad_file, 'DENEX')
    denexcep_value = get_population_value(bad_file, 'DENEXCEP')
    calculated_denominator = denom_value - ((denex_value || 0) + (denexcep_value || 0))
    expect(performance_rate_value == '0' && calculated_denominator.zero?).to be true
  end

  it 'test_performance_rate_out_of_range' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.performance_rate_out_of_range(Nokogiri::XML(@cat_3_file)))
    performance_rate = bad_file.at_css('code[code="72510-1"][codeSystem="2.16.840.1.113883.6.1"] ~ value').attributes['value'].value.to_f
    expect(performance_rate >= 1).to be true
  end

  # --- Validations for QRDA Category 1 ---
  it 'test_discharge_after_upload' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.discharge_after_upload(Nokogiri::XML(@cat_1_file)))
    upload_time = bad_file.at_css('ClinicalDocument effectiveTime').attributes['value'].value.to_i
    encounters_and_procedures = bad_file.css('encounter[classCode="ENC"], procedure[classCode="PROC"]').to_a
    discharge_times = []
    encounters_and_procedures.each { |item| discharge_times << item.at_css('effectiveTime high').attributes['value'].value.to_i }
    expect(discharge_times.any? { |discharge| discharge > upload_time }).to be true
  end

  it 'test_discharge_before_admission' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.discharge_before_admission(Nokogiri::XML(@cat_1_file)))
    encounters_and_procedures = bad_file.css('encounter[classCode="ENC"], procedure[classCode="PROC"]').to_a
    bad_discharge_times = 0
    encounters_and_procedures.each do |item|
      admission = item.at_css('effectiveTime low').attributes['value'].value.to_i
      discharge = item.at_css('effectiveTime high').attributes['value'].value.to_i
      bad_discharge_times += 1 if discharge < admission
    end
    expect(bad_discharge_times == 1).to be true
  end

  it 'test_incorrect_code_system' do
    good_file = Nokogiri::XML(@cat_1_file, &:noblanks)
    good_file_nodes = good_file.css('[codeSystem]').to_a
    bad_file = Nokogiri::XML(Cedar::Invalidator.incorrect_code_system(Nokogiri::XML(@cat_1_file, &:noblanks)))
    bad_file_nodes = bad_file.css('[codeSystem]').to_a
    expect(bad_file_nodes).to_not match_array(good_file_nodes)
  end

  it 'test_invalid_code' do
    good_file = Nokogiri::XML(@cat_1_file, &:noblanks)
    good_file_nodes = good_file.css('[code]').to_a
    bad_file = Nokogiri::XML(Cedar::Invalidator.invalid_code(Nokogiri::XML(@cat_1_file, &:noblanks)))
    bad_file_nodes = bad_file.css('[code]').to_a
    expect(bad_file_nodes).to_not match_array(good_file_nodes)
  end

  it 'test_invalid_value_set' do
    begin
      measure = HealthDataStandards::CQM::Measure.find_by(hqmf_id: '8A4D92B2-397A-48D2-0139-7CC6B5B8011E')
    rescue
      expect(measure).to_not be_nil
    end

    bad_file = Nokogiri::XML(Cedar::Invalidator.invalid_value_set(Nokogiri::XML(@cat_1_file), '8A4D92B2-397A-48D2-0139-7CC6B5B8011E'))
    nodes_with_value_set = bad_file.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a.collect(&:parent)
    valid_value_sets = %w(2.16.840.1.114222.4.11.3591
                          2.16.840.1.113883.3.117.1.7.1.424
                          2.16.840.1.113883.3.117.1.7.1.14
                          2.16.840.1.113883.3.117.1.7.1.247
                          2.16.840.1.113883.3.117.1.7.1.201
                          2.16.840.1.113883.3.117.1.7.1.292)
    invalid_value_sets = 0
    invalid_value_sets = 0
    nodes_with_value_set.each do |node|
      value_set = node.attributes['valueSet'].value
      invalid_value_sets += 1 if valid_value_sets.index[value_set].nil?
    end
    expect(invalid_value_sets == 1).to be true
  end

  it 'test_value_set_without_code_system' do
    bad_file = Nokogiri::XML(Cedar::Invalidator.value_set_without_code_system(Nokogiri::XML(@cat_1_file)))
    nodes_with_value_set = bad_file.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a.collect(&:parent)
    value_sets_without_code_system = 0
    nodes_with_value_set.each do |node|
      value_sets_without_code_system += 1 if node['codeSystem'].nil?
    end
    expect(value_sets_without_code_system == 1).to be true
  end

  private

  def get_population(file, pop)
    file.at_css('value[code="' + pop + '"] ~ entryRelationship[typeCode="SUBJ"] observation value')
  end

  def get_population_value(file, pop)
    get_population(file, pop).attributes['value'].value.to_i if get_population(file, pop)
  end
end
