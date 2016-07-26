---
layout: page
title: FAQ
permalink: /faq/
---

## What is Cedar?
Cedar is a free, open source tool for testing the strength of [Electronic Clinical Quality Measure (eCQM)](https://ecqi.healthit.gov/content/putting-ecqms-work) collection systems that receive [Quality Reporting Document Architecture (QRDA)](https://ecqi.healthit.gov/qrda) files.  It is being actively developed by the [Center for Medicaid and CHIP Services (CMCS)](https://www.medicaid.gov/about-us/organization/organization.html) with the help of [MITRE](http://mitre.org) and the [CMS Alliance to Modernize Healthcare (CAMH)](https://www.mitre.org/centers/cms-alliances-to-modernize-healthcare/who-we-are).

## Why is Cedar necessary?
QRDA is a relatively new standard for reporting clinical quality measures.  As such, many organizations are expected to receive QRDA files with errors.  Cedar will reveal whether an eCQM collection system can correctly identify and reject files with errors, such as…

- *Structural errors*, e.g. files that are missing information required to meet the QRDA standard
- *Calculation errors*, e.g. measures reported with a numerator greater than their denominator
-	*Contextual errors*, e.g. reported value sets that are not in the scope of a given measure definition

All of these errors have been encountered in the real world.  In the 2014 reporting period, [greater than 93% of QRDA Category 3 files contained errors](https://www.cms.gov/eHealth/downloads/2014_EP_Submission_Data_Issues.pdf).

## Who could benefit from using Cedar?
Any organization that collects QRDA files and uses them to assess the quality of delivered clinical care stands to benefit from the use of Cedar.  Currently, we are targeting these organizations in particular:

-	State Medicaid and Health and Human Services agencies
-	Quality Improvement Organizations
-	Health Information Exchanges
- Health Information Service Providers

As Cedar is a tool geared toward data analysis at a very low level, users are expected to have at least a cursory knowledge of the [QRDA standard](https://ecqi.healthit.gov/qrda) and be able to understand and modify those files.  While the tool is potentially usable by Business Analysts, it is expected that users with a background in programming will gain the most from Cedar.

## How does Cedar work?
Cedar takes users through a guided process to generate tests that can be run on an eCQM collection system.

1. The user asks Cedar for test files based on the type of QRDA files to generate, which reporting period to use, how many and what types of validations to use, etc.
2. Cedar generates QRDA files – some with errors and some without any errors.
3. The user takes the QRDA files and feeds them into their eCQM collection system, noting which files were accepted and which were rejected.
4. The user returns to Cedar and inputs the results from their eCQM collection system test (acceptance/rejection). Cedar then shows a comparison of the expected and actual recorded results of the test.

## What is the technical architecture for Cedar?
<div class='grid-half padded' style='text-align:center;'>
  <a href='http://rubyonrails.org/'><img src='../images/rails-logo.png' alt='Rails Logo' style='height:100px;'></a>
</div>
<div class='grid-half padded' style='text-align:center;'>
  <a href='https://www.mongodb.com/'><img src='../images/MongoDB-Logo.png' alt='MongoDB Logo' style='height:100px;'></a>
</div>
Cedar is a web-based Ruby on Rails application that sits on a Mongo database.  It can be deployed locally on a laptop or hosted on a server to allow for multiple users within an organization to access the same instance.

## Where did Cedar come from?
Cedar shares many libraries with [Cypress](http://projectcypress.org/), [Bonnie](https://bonnie.healthit.gov/), and [popHealth](http://projectpophealth.org/).  All of these tools were developed by [MITRE](http://mitre.org) and the [CMS Alliance to Modernize Healthcare (CAMH)](https://www.mitre.org/centers/cms-alliances-to-modernize-healthcare/who-we-are) in an attempt to improve the eCQM lifecycle in the United States.

## How can my organization use Cedar?
Cedar is totally free and available as open source under Apache 2.0 licensing, so you can [download the code on GitHub](http://github.com/mitre/cedar) and install it whenever you like.
