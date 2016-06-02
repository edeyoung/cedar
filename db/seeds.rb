Validation.create(
  'code' => 'discharge_after_upload', 'description' => 'Among the encounter events in a QRDA category 1 file, all discharge dates should be before the file upload date.  In this file, a randomly selected encounter will have a discharge date after the file upload date.', 'name' => 'Discharge After Upload', 'overview_text' => 'In this file, a randomly selected encounter had a discharge date after the file upload date. The file should be rejected.', 'qrda_type' => '1'
)
Validation.create(
  'code' => 'discharge_before_admission', 'description' => 'Among the encounter events in a QRDA category 1 file, all discharge dates should be after the admission date. In this file, a randomly selected encounter will have a discharge date before its admission date.', 'name' => 'Discharge Before Admission', 'overview_text' => 'In this file, a randomly selected encounter had a discharge date before its admission date. The file should be rejected.', 'qrda_type' => '1'
)
Validation.create(
  'code' => 'incorrect_code_system', 'description' => 'For each code in a QRDA file, the corresponding code system (e.g., LOINC, SNOMED) should also be reported.  In this file, the OID of one of the existing code systems will be replaced by the OID of another.', 'name' => 'Incorrect Code System', 'overview_text' => 'In this file, the OID of one of the existing code systems was replaced by the OID of another.  This invalidates the reported code and the file should be rejected.', 'qrda_type' => '1'
)
Validation.create(
  'code' => 'invalid_value_set', 'description' => 'Each measure contains a limited scope of value sets, as determined by the eCQM specification.  In this file, one of the value set OIDs will be replaced by an OID that is not useful for calculating this measure.', 'name' => 'Invalid Value Set', 'overview_text' => 'In this file, one of the value set OIDs was replaced by an OID that is not useful for calculating this measure.', 'qrda_type' => '1'
)
Validation.create(
  'code' => 'value_set_without_code_system', 'description' => 'All value sets in a QRDA file should be accompanied by the OID of their respective code systems.  In this file, one of the code systems for a given value set will be removed.', 'name' => 'Value Set without Code System', 'overview_text' => 'In this file, one of the code systems for a given value set was removed.', 'qrda_type' => '1'
)
Validation.create(
  'code' => 'denom_greater_than_ipp', 'description' => 'For discrete measures, the denominator should always be less than or equal to the initial patient population.  In this file, the submitted denominator will be made greater than the initial patient population.', 'name' => 'Denominator Greater Than IPP', 'overview_text' => 'In this file, the submitted denominator was greater than the initial patient population. In discrete eCQMs, the denominator should always be less than or equal to the initial patient population.', 'qrda_type' => '3'
)
Validation.create(
  'code' => 'duplicate_population_ids', 'description' => 'Within a QRDA Cat 3 file, measure population IDs should only exist once.  In this file, one of the measure populations (e.g., IPP, Numerator, Observed Value, etc.) will be reported twice.', 'name' => 'Duplicated Measure Population IDs', 'overview_text' => 'In this file, one of the measure populations (e.g., IPP, Numerator, Observed Value, etc.) was reported twice.  For a given measure, these populations should be reported once and only once.', 'qrda_type' => '3'
)
Validation.create(
  'code' => 'numer_greater_than_denom', 'description' => 'For discrete measures, the numerator should always be less than the denominator.  In this file, the submitted numerator will be greater than the denominator.', 'name' => 'Numerator Greater Than Denominator', 'overview_text' => 'In this file, the submitted numerator was greater than the denominator.  Discrete eCQMs should be a ratio less than one.', 'qrda_type' => '3'
)
Validation.create(
  'code' => 'reporting_period', 'description' => 'There is a known set of reporting periods for QRDA files (currently, 2014, 2015, 2016, and 2017).  The reporting period in this file will be dated far outside of those expected reporting periods.', 'name' => 'Reporting Period', 'overview_text' => 'The reporting period for this QRDA document was dated outside of the reporting year and the file should have been rejected.', 'qrda_type' => 'all'
)
Validation.create(
  'code' => 'unfinished_file', 'description' => 'QRDA files must be completed according to the HL7 file specification and the CMS Implementation Guide. This file will be bifurcated, leaving an incomplete file to simulate an error with the file transfer process.', 'name' => 'Unfinished QRDA file', 'overview_text' => 'The latter half of this file was deleted to represent a file transfer error that would result in an unfinished QRDA file.  It should be rejected outright.', 'qrda_type' => 'all'
)