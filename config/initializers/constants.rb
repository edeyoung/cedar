# Globally available constants
BUNDLE_MAP = { '2016' => 1_388_534_400,
               '2015' => 1_356_998_400,
               '2014' => 1_325_376_000 }.freeze
CV_POPULATION_KEYS = %w(IPP MSRPOPL MSRPOPLEX OBSERV).freeze
REQUIRED_CV_POPULATION_KEYS = %w(IPP MSRPOPL OBSERV).freeze
PROPORTION_POPULATION_KEYS = %w(IPP DENOM NUMER DENEX DENEXCEP).freeze
REQUIRED_PROPORTION_POPULATION_KEYS = %w(IPP DENOM NUMER).freeze
CODE_SYSTEM_OIDS = %w(2.16.840.1.113883.6.96
                      2.16.840.1.113883.6.88
                      2.16.840.1.113883.6.1
                      2.16.840.1.113883.6.8
                      2.16.840.1.113883.3.26.1.2
                      2.16.840.1.113883.6.12
                      2.16.840.1.113883.6.209
                      2.16.840.1.113883.4.9
                      2.16.840.1.113883.6.69
                      2.16.840.1.113883.12.292
                      1.0.3166.1.2.2
                      2.16.840.1.113883.6.301.5
                      2.16.840.1.113883.6.256
                      2.16.840.1.113883.6.3 
                      1.2.276.0.76.5.409 
                      2.16.840.1.113883.6.3.2 
                      2.16.840.1.113883.6.4
                      2.16.840.1.113883.6.42 
                      2.16.840.1.113883.6.103 
                      2.16.840.1.113883.6.104
                      2.16.840.1.113883.2.4.4.31.1 
                      2.16.840.1.113883.6.139
                      2.16.840.1.113883.6.254
                      2.16.840.1.113883.6.73
                      2.16.840.1.113883.6.24
                      1.2.840.10008.2.16.4).freeze

# Find all the valid measure ids
all_valid_measure_ids = []
HealthDataStandards::CQM::Measure.all.each do |measure|
  all_valid_measure_ids << measure.hqmf_id
  all_valid_measure_ids << measure.hqmf_set_id
end
ALL_VALID_MEASURE_IDS = all_valid_measure_ids.freeze

# Find all the valid codes in value sets
all_value_set_codes = []
HealthDataStandards::SVS::ValueSet.each { |vs| vs.concepts.each { |concept| all_value_set_codes << concept.code } }
all_value_set_codes.uniq!
ALL_VALUE_SET_CODES = all_value_set_codes.freeze

# Find all the valid oids for value sets
all_value_set_oids = []
HealthDataStandards::SVS::ValueSet.each { |vs| all_value_set_oids << vs.oid }
all_value_set_oids.uniq!
ALL_VALUE_SET_OIDS = all_value_set_oids.freeze
