---
layout: page
title: FAQ
permalink: /faq/
---

## What is Cedar?
Cedar is a free, open source tool for testing the strength of Electronic Clinical Quality Measure (eCQM) collection systems that receive Quality Reporting Document Architecture (QRDA) files.  It is being actively developed by CMS/CMCS with the help of CAMH.

## Why is Cedar necessary?
QRDA is a relatively new standard for reporting clinical quality measures.  As such, it is expected that many organizations may receive QRDA files with errors.  Cedar will show you if your eCQM collection system can correctly identify and reject files with errors, such as…

- Structural Errors, e.g. files that are missing information required to meet the QRDA standard
- Calculation Errors, e.g. measures reported with a numerator greater than their denominator
-	Contextual Errors, e.g. reported value sets that are not in the scope of a given measure definition

All of these errors have been encountered in the real world.  In the 2014 reporting period, [greater than 93% of QRDA Category 3 files contained errors](https://www.cms.gov/eHealth/downloads/2014_EP_Submission_Data_Issues.pdf).

## Who could benefit from using Cedar?
Any organization that collects QRDA files and uses them to assess the quality of delivered clinical care stands to benefit from the use of Cedar.  Currently, we are targeting these organizations in particular:

-	State Medicaid and Health and Human Services agencies
-	Quality Improvement Organizations
-	Health Information Exchanges

Currently, MITRE is working with the Michigan Health Information Network (MiHIN) to pilot development and usage of Cedar in a production setting.

## How does Cedar work?
Cedar takes users through a guided process to generate tests that can be run on an eCQM collection system.

1. The user asks for test files based on the type of QRDA files to generate, which reporting period to use, how many and what types of validations to use, etc.
2. Cedar generates QRDA files – some with errors, some without – to be used in a blind test of the eCQM collection system
3. Users take the QRDA files and process them in their eCQM collection system, noting any rejections
4. Users return to Cedar and record the results of their test (which files were rejected/accepted)
5. Cedar shows a comparison of the expected and actual recorded results of the test

## What is the technical architecture for Cedar?
Cedar is a web-based Ruby on Rails application that sits on a Mongo database.  It can be deployed locally on a laptop or hosted on a server to allow for multiple users within an organization to access the same instance.

## How can my organization use Cedar?
Cedar is totally free and available as open source under Apache 2.0 licensing, so you can download the code on GitHub and install it whenever you like: http://github.com/mitre/cedar.
