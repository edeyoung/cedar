Validation.create(
  'code' => 'discharge_after_upload',
  'description' => 'Among the encounter and procedure events in a QRDA category 1 file, all discharge dates should be before the file upload date.  In this file, a randomly selected encounter or procedure will have a discharge date after the file upload date.',
  'name' => 'Discharge After Upload',
  'overview_text' => 'In this file, a randomly selected encounter or procedure had a discharge date after the file upload date. The file should be rejected.',
  'qrda_type' => '1',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'discharge_before_admission',
  'description' => 'Among the encounter and procedure events in a QRDA category 1 file, all discharge dates should be after the admission date. In this file, a randomly selected encounter or procedure will have a discharge date before its admission date.',
  'name' => 'Discharge Before Admission',
  'overview_text' => 'In this file, a randomly selected encounter or procedure had a discharge date before its admission date. The file should be rejected.',
  'qrda_type' => '1',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'incorrect_code_system',
  'description' => 'For each code in a QRDA file, the corresponding code system (e.g., LOINC, SNOMED) should also be reported.  In this file, the OID of one of the existing code systems will be replaced by the OID of another.',
  'name' => 'Incorrect Code System',
  'overview_text' => 'In this file, the OID of one of the existing code systems was replaced by the OID of another.  This invalidates the reported code and the file should be rejected.',
  'qrda_type' => '1',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'invalid_code',
  'description' => 'Each code reported in a QRDA document must belong to the specified Value Set. In this file, one of the existing codes will be replaced by a code that is not valid for the value set.',
  'name' => 'Invalid Code',
  'overview_text' => 'In this file, one of the existing codes was replaced by a code that is not valid for the value set.',
  'qrda_type' => '1',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'invalid_value_set',
  'description' => 'Each measure contains a limited scope of value sets, as determined by the eCQM specification.  In this file, one of the value set OIDs will be replaced by an OID that is not useful for calculating this measure.',
  'name' => 'Invalid Value Set',
  'overview_text' => 'In this file, one of the value set OIDs was replaced by an OID that is not useful for calculating this measure.',
  'qrda_type' => '1',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'value_set_without_code_system',
  'description' => 'All value sets in a QRDA file should be accompanied by the OID of their respective code systems.  In this file, one of the code systems for a given value set will be removed.',
  'name' => 'Value Set without Code System',
  'overview_text' => 'In this file, one of the code systems for a given value set was removed.',
  'qrda_type' => '1',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'denom_greater_than_ipp',
  'description' => 'For discrete measures, the denominator should always be less than or equal to the initial patient population.  In this file, the submitted denominator will be made greater than the initial patient population.',
  'name' => 'Denominator Greater Than IPP',
  'overview_text' => 'In this file, the submitted denominator was greater than the initial patient population. In discrete eCQMs, the denominator should always be less than or equal to the initial patient population.',
  'qrda_type' => '3',
  'measure_type' => 'discrete'
)
Validation.create(
  'code' => 'duplicate_population_ids',
  'description' => 'Within a QRDA Cat 3 file, measure population IDs should only exist once.  In this file, one of the measure populations (e.g., IPP, Numerator, Observed Value, etc.) will be reported twice.',
  'name' => 'Duplicated Measure Population IDs',
  'overview_text' => 'In this file, one of the measure populations (e.g., IPP, Numerator, Observed Value, etc.) was reported twice.  For a given measure, these populations should be reported once and only once.',
  'qrda_type' => '3',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'numer_greater_than_denom',
  'description' => 'For discrete measures, the numerator should always be less than the denominator.  In this file, the submitted numerator will be greater than the denominator.',
  'name' => 'Numerator Greater Than Denominator',
  'overview_text' => 'In this file, the submitted numerator was greater than the denominator.  Discrete eCQMs should be a ratio less than one.',
  'qrda_type' => '3',
  'measure_type' => 'discrete'
)
Validation.create(
  'code' => 'performance_rate_out_of_range',
  'description' => 'According to the QRDA specification, the performance rate for a discrete measure in a QRDA Cat 3 file should be between zero and one. In this file, the performance rate was replaced with a number that is outside of that range.',
  'name' => 'Performance Rate Out of Range',
  'overview_text' => 'In this file, the performance rate was replaced with a number that is outside the acceptable range (a floating point number between 0 and 1).',
  'qrda_type' => '3',
  'measure_type' => 'discrete'
)
Validation.create(
  'code' => 'invalid_measure_id',
  'description' => 'Measures are identified by their HQMF IDs, as output by the Measure Authoring Tool. In this file, a valid HQMF ID will be replaced with an invalid GUID.',
  'name' => 'Invalid Measure ID',
  'overview_text' => 'In this file, a valid HQMF ID or HQMF Set ID was be replaced with an invalid GUID.',
  'qrda_type' => 'all',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'reporting_period',
  'description' => 'There is a known set of reporting periods for QRDA files (currently, 2014, 2015, 2016, and 2017).  The reporting period in this file will be dated far outside of those expected reporting periods.',
  'name' => 'Reporting Period',
  'overview_text' => 'The reporting period for this QRDA document was dated outside of the reporting year and the file should have been rejected.',
  'qrda_type' => 'all',
  'measure_type' => 'all'
)
Validation.create(
  'code' => 'unfinished_file',
  'description' => 'QRDA files must be completed according to the HL7 file specification and the CMS Implementation Guide. This file will be bifurcated, leaving an incomplete file to simulate an error with the file transfer process.',
  'name' => 'Unfinished QRDA file',
  'overview_text' => 'The latter half of this file was deleted to represent a file transfer error that would result in an unfinished QRDA file.  It should be rejected outright.',
  'qrda_type' => 'all',
  'measure_type' => 'all'
)
