require 'test_helper'
require 'fileutils'
require 'nokogiri'

# Unit test cases for all of the Cedar invalidators
class InvalidatorTest < ActiveSupport::TestCase
  setup do
    @cat_1_file = IO.read('test/fixtures/qrda/cat_1/good.xml')
    @cat_3_file = IO.read('test/fixtures/qrda/cat_3/good.xml')
  end

  # --- Validations for both QRDA Category 1 and Category 3 ---
  def test_inconsistent_time_formats
    bad_file = Nokogiri::XML(Cedar::Invalidator.inconsistent_time_formats(Nokogiri::XML(@cat_1_file)))
    all_times = bad_file.css('effectiveTime low[value], effectiveTime high[value], effectiveTime [value]').to_a
    invalid_times = 0
    all_times.each { |time| invalid_times += 1 if time.attributes['value'].value.length > 14 }
    assert(invalid_times == 1, 'All time formats appear to be similar')
  end

  def test_invalid_measure_id
    # Find all the valid measure ids
    valid_measure_ids = []
    HealthDataStandards::CQM::Measure.all.each do |measure|
      valid_measure_ids << measure.hqmf_id
      valid_measure_ids << measure.hqmf_set_id
    end
    assert(valid_measure_ids != [], 'No measures are loaded in the test database')
    # Test the measure IDs to see if they are valid
    bad_file = Nokogiri::XML(Cedar::Invalidator.invalid_measure_id(Nokogiri::XML(@cat_1_file)))
    measure_id = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.98"] ~ reference externalDocument id').attributes['extension'].value
    set_id = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.24.3.98"] ~ reference externalDocument setId').attributes['root'].value
    assert(valid_measure_ids.include?(measure_id) && valid_measure_ids.include?(set_id), 'The measure HQMF ID and HQMF Set ID appear to be valid')
  end

  def test_reporting_period
    bad_file = Nokogiri::XML(Cedar::Invalidator.reporting_period(Nokogiri::XML(@cat_1_file)))
    period_start = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.17.3.8"] ~ effectiveTime low').attributes['value'].value.to_i
    period_end = bad_file.at_css('templateId[root="2.16.840.1.113883.10.20.17.3.8"] ~ effectiveTime high').attributes['value'].value.to_i
    # TODO: Find out the valid reporting periods from the uploaded bundle files and use that instead
    assert(period_start > 20_300_101_000_000 && period_end > 20_300_101_000_000, 'The reporting period was probably not changed')
  end

  def test_unfinished_file
    bad_file = Nokogiri::XML(Cedar::Invalidator.unfinished_file(@cat_3_file))
    assert(bad_file.errors.length > 1, 'The file appears to be complete')
  end

  # --- Validations for QRDA Category 3 ---
  def test_denom_greater_than_ipp
    bad_file = Nokogiri::XML(Cedar::Invalidator.denom_greater_than_ipp(Nokogiri::XML(@cat_3_file)))
    ipp_value = get_population_value(bad_file, 'IPP')
    denom_value = get_population_value(bad_file, 'DENOM')
    assert(denom_value >= ipp_value, 'The DENOM value is less than or equal to the IPP value')
  end

  def test_duplicate_population_ids
    bad_file = Nokogiri::XML(Cedar::Invalidator.duplicate_population_ids(Nokogiri::XML(@cat_3_file)))
    # Find a random population in the file to duplicate
    all_populations_search = ''
    (CV_POPULATION_KEYS + PROPORTION_POPULATION_KEYS).uniq.each do |id|
      all_populations_search += 'value[code="' + id + '"] ~ reference externalObservation id[root], '
    end
    population_ids = bad_file.css(all_populations_search.chomp(', ')).to_a.map { |pop| pop.attributes['root'].value }
    assert(population_ids.count - population_ids.uniq.count == 1, 'All of the population ids are unique')
  end

  def test_missing_population_id
    bad_file = Nokogiri::XML(Cedar::Invalidator.missing_population_id(Nokogiri::XML(@cat_3_file)))
    required_population_keys = REQUIRED_PROPORTION_POPULATION_KEYS
    required_populations_search = ''
    required_population_keys.uniq.each { |id| required_populations_search += 'value[code="' + id + '"], ' }
    required_populations = bad_file.css(required_populations_search.chomp(', ')).to_a
    assert(required_populations.length < required_population_keys.length, 'All of the required population exist in this file')
  end

  def test_numer_greater_than_denom
    bad_file = Nokogiri::XML(Cedar::Invalidator.numer_greater_than_denom(Nokogiri::XML(@cat_3_file)))
    numer_value = get_population_value(bad_file, 'NUMER')
    denom_value = get_population_value(bad_file, 'DENOM')
    assert(numer_value >= denom_value, 'The NUMER value is less than or equal to the DENOM value')
  end

  def test_performance_rate_divide_by_zero
    bad_file = Nokogiri::XML(Cedar::Invalidator.performance_rate_divide_by_zero(Nokogiri::XML(@cat_3_file)))
    performance_rate_value = bad_file.at_css('code[code="72510-1"][codeSystem="2.16.840.1.113883.6.1"] ~ value').attributes['value'].value
    denom_value = get_population_value(bad_file, 'DENOM')
    denex_value = get_population_value(bad_file, 'DENEX')
    denexcep_value = get_population_value(bad_file, 'DENEXCEP')
    calculated_denominator = denom_value - ((denex_value || 0) + (denexcep_value || 0))
    assert(performance_rate_value == '0' && calculated_denominator == 0, 'The performance rate does not contain a divide by zero error.')
  end

  def test_performance_rate_out_of_range
    bad_file = Nokogiri::XML(Cedar::Invalidator.performance_rate_out_of_range(Nokogiri::XML(@cat_3_file)))
    performance_rate = bad_file.at_css('code[code="72510-1"][codeSystem="2.16.840.1.113883.6.1"] ~ value').attributes['value'].value.to_f
    assert(performance_rate >= 1, 'The performance rate is within the acceptable range (0 to 1)')
  end

  # --- Validations for QRDA Category 1 ---
  def test_discharge_after_upload
    bad_file = Nokogiri::XML(Cedar::Invalidator.discharge_after_upload(Nokogiri::XML(@cat_1_file)))
    upload_time = bad_file.at_css('ClinicalDocument effectiveTime').attributes['value'].value.to_i
    encounters_and_procedures = bad_file.css('encounter[classCode="ENC"], procedure[classCode="PROC"]').to_a
    discharge_times = []
    encounters_and_procedures.each { |item| discharge_times << item.at_css('effectiveTime high').attributes['value'].value.to_i }
    assert(discharge_times.any? { |discharge| discharge > upload_time }, 'None of the discharge dates are after the upload date')
  end

  def test_discharge_before_admission
    bad_file = Nokogiri::XML(Cedar::Invalidator.discharge_before_admission(Nokogiri::XML(@cat_1_file)))
    encounters_and_procedures = bad_file.css('encounter[classCode="ENC"], procedure[classCode="PROC"]').to_a
    bad_discharge_times = 0
    encounters_and_procedures.each do |item|
      admission = item.at_css('effectiveTime low').attributes['value'].value.to_i
      discharge = item.at_css('effectiveTime high').attributes['value'].value.to_i
      bad_discharge_times += 1 if discharge < admission
    end
    assert(bad_discharge_times == 1, 'None of the discharge dates are before their respective admission dates')
  end

  def test_incorrect_code_system
    # Create an array of all codes with their respective code systems
    all_valid_codes = []
    HealthDataStandards::SVS::ValueSet.each do |vs|
      vs.concepts.each { |concept| all_valid_codes << [concept.code, concept.system] }
    end
    all_valid_codes.uniq!
    assert(all_valid_codes != [], 'No value sets are loaded in the test database')
    bad_file = Nokogiri::XML(Cedar::Invalidator.incorrect_code_system(Nokogiri::XML(@cat_1_file)))
    nodes_with_code_system = bad_file.css('[codeSystem]').to_a
    bad_code_systems = 0
    nodes_with_code_system.each do |node|
      code = node.attributes['code'].value
      code_system = node.attributes['codeSystem'].value
      # Attempt to find the code/codeSystem pair in the value sets database
      bad_code_systems += 1 unless all_valid_codes.include? [code, code_system]
    end
    assert(bad_code_systems == 1, 'All of the code systems seem to be correct for their respective codes')
  end

  def test_invalid_code
    # Loop through the value sets to find a master list of unique, valid codes
    all_codes = []
    HealthDataStandards::SVS::ValueSet.each { |vs| vs.concepts.each { |concept| all_codes << concept.code } }
    all_codes.uniq!
    assert(all_codes != [], 'No value sets are loaded in the test database')
    nodes_with_value_set = bad_file.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a
    bad_codes = 0
    nodes_with_value_set.each do |node|
      code = node.attributes['code'].value
      value_set = HealthDataStandards::SVS::ValueSet.find_by(oid: node_with_value_set.attributes['valueSet'].value)
      valid_codes = []
      value_set.concepts.each { |vs| valid_codes << vs.code }
      bad_codes += 1 unless valid_codes.include? code
    end
    assert(bad_code_systems == 1, 'All of the codes seem to be valid for their respective value sets')
  end

  def test_invalid_value_set
    begin
      measure = HealthDataStandards::CQM::Measure.find_by(hqmf_id: '40280381-4C72-51DF-014C-8F7B539207A9')
    rescue
      assert(!measure.nil?, 'Check the test fixtures - a measure is missing in the test database')
    end
    bad_file = Nokogiri::XML(Cedar::Invalidator.invalid_value_set(Nokogiri::XML(@cat_1_file), '40280381-4C72-51DF-014C-8F7B539207A9'))
    nodes_with_value_set = bad_file.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a.collect(&:parent)
    valid_value_sets = %w(2.16.840.1.114222.4.11.3591
                          2.16.840.1.113883.3.117.1.7.1.424
                          2.16.840.1.113883.3.117.1.7.1.14
                          2.16.840.1.113883.3.117.1.7.1.247
                          2.16.840.1.113883.3.117.1.7.1.201
                          2.16.840.1.113883.3.117.1.7.1.292)
    invalid_value_sets = 0
    nodes_with_value_set.each do |node|
      value_set = node.attributes['valueSet'].value
      invalid_value_sets += 1 if valid_value_sets.index[value_set].nil?
    end
    assert(invalid_value_sets == 1, 'All of the value sets appear to be correct for this measure')
  end

  def test_value_set_without_code_system
    bad_file = Nokogiri::XML(Cedar::Invalidator.value_set_without_code_system(Nokogiri::XML(@cat_1_file)))
    nodes_with_value_set = bad_file.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a.collect(&:parent)
    value_sets_without_code_system = 0
    nodes_with_value_set.each do |node|
      value_sets_without_code_system += 1 if node['codeSystem'].nil?
    end
    assert(value_sets_without_code_system == 1, 'All of the nodes with value sets have a corresponding code system')
  end

  private

  def get_population(file, pop)
    file.at_css('value[code="' + pop + '"] ~ entryRelationship[typeCode="SUBJ"] observation value')
  end

  def get_population_value(file, pop)
    get_population(file, pop).attributes['value'].value.to_i if get_population(file, pop)
  end
end
