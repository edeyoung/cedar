module Cedar
  class Invalidator
    # Grab the text and validation code, then send it to the naughty methods below
    def self.invalidate_qrda(doc)
      text = doc.qrda
      validation_code = Validation.find(doc.validation_id)['code']
      if validation_code == 'invalid_value_set'
        doc.qrda = invalid_value_set(Nokogiri::XML(text), doc.measure_id)
      elsif validation_code == 'unfinished_file'
        doc.qrda = send validation_code, text
      else
        doc.qrda = send validation_code, Nokogiri::XML(text) unless validation_code.blank?
      end
    end

    # Per Sam, consider refactoring like this...
    # VALIDATORS = {reporting_period: Cedar::ReportingPeriodInvalidator.new(2014, 2015)}
    # files.each do |file|
    #   VALIDATORS[file.code].validate(file.doc)
    # end

    # --- Validations for both QRDA Category 1 and Category 3 ---
    def self.reporting_period(doc)
      # Change the text description
      doc.at_css('item:contains("Reporting period")').content = 'Reporting period: end of the world'
      # Mangle the start of the reporting period
      start = doc.at_css('templateId[root="2.16.840.1.113883.10.20.17.3.8"] ~ effectiveTime low')
      start.attributes['value'].value = '30000101000000'
      # Mangle the end of the reporting period
      finish = doc.at_css('templateId[root="2.16.840.1.113883.10.20.17.3.8"] ~ effectiveTime high')
      finish.attributes['value'].value = '30010101000000'
      doc.to_xml
      # TODO: better, more random dates?
    end

    def self.unfinished_file(doc)
      doc.slice!(0..(doc.length / 2))
    end

    # --- Validations for QRDA Category 3 ---
    def self.denom_greater_than_ipp(doc)
      # TODO: Filter out continuous measures for this validation (and potentially others)
      # Find the IPP and DENOM
      ipp = doc.at_css('value[code="IPP"] ~ entryRelationship[typeCode="SUBJ"] observation value')
      denom = doc.at_css('value[code="DENOM"] ~ entryRelationship[typeCode="SUBJ"] observation value')
      ipp_value = ipp.attributes['value'].value.to_i
      # Add a random amount to IPP and store it in DENOM
      denom_value = ipp_value + Random.new.rand(1..10)
      denom.attributes['value'].value = denom_value.to_s
      doc.to_xml
    end

    def self.duplicate_population_ids(doc)
      # Find a random population in the file to duplicate
      all_populations_search = ''
      (CV_POPULATION_KEYS + PROPORTION_POPULATION_KEYS).uniq.each { |id| all_populations_search += 'value[code="' + id + '"], ' }
      random_population = doc.css(all_populations_search.chomp(', ')).to_a.sample.parent.parent
      # Duplicate it at the end of the parent organizer
      random_population.parent << random_population.dup
      doc.to_xml
    end

    def self.numer_greater_than_denom(doc)
      # TODO: Filter out continuous measures for this validation (and potentially others)
      # Find the NUMER and DENOM
      numer = doc.at_css('value[code="NUMER"] ~ entryRelationship[typeCode="SUBJ"] observation value')
      denom = doc.at_css('value[code="DENOM"] ~ entryRelationship[typeCode="SUBJ"] observation value')
      denom_value = denom.attributes['value'].value.to_i
      # Add a random amount to DENOM and store it in NUMER
      numer_value = denom_value + Random.new.rand(1..10)
      numer.attributes['value'].value = numer_value.to_s
      doc.to_xml
    end

    def self.performance_rate_out_of_range(doc)
      performance_rate = doc.at_css('code[code="72510-1"][codeSystem="2.16.840.1.113883.6.1"] ~ value')
      bad_performance = Random.new.rand(1.001..2.000).to_s
      performance_rate.attributes['value'].value = bad_performance
      doc.to_xml
    end

    # --- Validations for QRDA Category 1 ---
    def self.discharge_after_upload(doc)
      # Find the upload time
      upload_time = doc.at_css('ClinicalDocument effectiveTime').attributes['value'].value
      # Pick a random encounter or procedure
      encounter_or_procedure = doc.css('encounter[classCode="ENC"], procedure[classCode="PROC"]').to_a.sample
      # Add a random number of days from admission TODO: Subtract time?
      bad_discharge = (Date.parse(upload_time) + Random.new.rand(1..5)).strftime('%Y%m%d%H%M%S')
      encounter_or_procedure.at_css('effectiveTime high').attributes['value'].value = bad_discharge
      doc.to_xml
    end

    def self.discharge_before_admission(doc)
      # Pick a random encounter or procedure
      encounter_or_procedure = doc.css('encounter[classCode="ENC"], procedure[classCode="PROC"]').to_a.sample
      # Find the admission date/time
      admission = encounter_or_procedure.at_css('effectiveTime low').attributes['value'].value
      # Subtract a random number of days from admission TODO: Subtract time?
      bad_discharge = (Date.parse(admission) - Random.new.rand(1..5)).strftime('%Y%m%d%H%M%S')
      encounter_or_procedure.at_css('effectiveTime high').attributes['value'].value = bad_discharge
      doc.to_xml
    end

    def self.incorrect_code_system(doc)
      # Find a random node with a code system
      node_with_code_system = doc.css('[codeSystem]').to_a.sample
      # Generate a random incorrect code system
      incorrect_code_system = (CODE_SYSTEM_OIDS - [node_with_code_system.attributes['codeSystem'].value]).sample
      # Inject the incorrect code system into the random node
      node_with_code_system.attributes['codeSystem'].value = incorrect_code_system
      doc.to_xml
    end

    def self.invalid_value_set(doc, measure_id)
      # TODO: Move the generation of all_measure_oids elsewhere
      all_measure_oids = []
      HealthDataStandards::SVS::ValueSet.each { |vs| all_measure_oids << vs.oid }
      all_measure_oids.uniq!
      # FIXME: This is assuming that there are measures in test database (which are currently only in the dev db)
      measure = HealthDataStandards::CQM::Measure.find_by(hqmf_id: measure_id)
      # Pick a random value set in the file
      sample_value_set = doc.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a.sample
      # Inject a value set that should not be used for that measure
      sample_value_set.value = (all_measure_oids - measure.oids).sample
      # TODO: Should I update the text as well?
      doc.to_xml
    end

    def self.value_set_without_code_system(doc)
      # Pick a random value set in the file
      node_with_value_set = doc.xpath('//@sdtc:valueSet', xmlns: 'urn:hl7-org:v3', sdtc: 'urn:hl7-org:sdtc').to_a.sample.parent
      # Remove the code system from that node
      node_with_value_set.remove_attribute('codeSystem')
      doc.to_xml
    end
  end
end
