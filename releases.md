---
layout: page
title: Releases
permalink: /releases/
---

Cedar development began in January 2016 on MITRE servers and was released to GitHub on May 25th, 2016.  Release schedules are set based on planned functionality rather than on a set timeline.

## Version 0.4 (TBD)
- Allow user-specified modifications to the QRDA header
- Improve performance of QRDA Category 3 file generation
- Allow for a user-specified number of QRDA documents to be generated in each test
- Generate QRDA files using the Joint Commission IG in addition to the CMS IG
- Dashboard showing validation coverage over time


## Version 0.3 (Planned for October 2016)

New project staffing and the pending MACRA final rule limited the potential for new functionality
this release cycle.

### New Functionality

- Add UI Unit and Integration Tests

### Bug Fixes

- Invalid measure id test was not inserting an invalid guid for the 'root' id.
- Fixed performance rate bug.

## [Version 0.2](https://github.com/mitre/cedar/releases/tag/v0.2) (August 10, 2016)

### New Functionality

- Add the ability to upload multiple measure bundles for multiple reporting years
- Add docker configuration files and some setup instructions
- Add v1 of the Cedar API
- Add several invalidators and their respective unit tests
  - Invalid Code
  - Invalid Measure Identifier
  - Inconsistent Time Formats
  - Missing Population ID
  - Performance Rate Divide by Zero
  - Performance Rate Out of Range
- Add configuration pages for measures and validations
- Add the ability for users to tag and filter measures and validations so they can be more quickly accessed and used during test executions
- Add an index number for each of the documents created in a test execution
- Improve randomization of patient information in QRDA I files
- Improve the random names given to documents created in a test execution - they now pull from a list of actual hospitals in the United States

### Bug Fixes

- Extra database cache records no longer created on test execution process runs
- Incorporate error checking to prevent invalid reporting year/measure/validation combinations
- Hardcode some constants to speed up server startup
- Fix rails pipeline errors

## [Version 0.1](https://github.com/mitre/cedar/releases/tag/v0.1) (May 25, 2016)

### New Functionality

- Generate both QRDA Category 1 and Category 3 files
- Validations included for testing eCQM collection systems:
  - Denominator Greater Than IPP
  - Discharge After Upload
  - Discharge Before Admission
  - Duplicated Measure Population IDs
  - Incorrect Code System
  - Invalid Value Set
  - Numerator Greater Than Denominator
  - Reporting Period
  - Unfinished QRDA file
  - Value Set without Code System
