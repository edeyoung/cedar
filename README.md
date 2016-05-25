Cedar
=====
Cedar is a tool for testing the strength of Electronic Clinical Quality Measure (eCQM) collection systems that receive Quality Reporting Document Architecture (QRDA) files. The Cedar tool is open source and freely available for use or adoption by state health agencies or any other organization that is set up to receive QRDA files.

To report a software bug, submit a feature request, or leave usability feedback, please use the [Cedar issue tracker](https://github.com/mitre/cedar/issues).  For all other questions, comments, or concerns, email <mailto:cedar-feedback-list@lists.mitre.org>.

Technical Architecture
======================
Cedar is a Ruby on Rails application with a mongo database backend.  Wherever possible, Cedar attempts to conform to rails conventions.

**Note: below you will find instructions for using Cedar on unix-based systems.  A windows-based version of Cedar is planned, but is not currently available**

Application Dependencies
========================
To start a local installation of Cedar, ensure that you have done the following:
1. Download and install `xcode` and `xcode developer tools` from the app store (OSX only)
2. Install [homebrew](http://brew.sh/): `brew link openssl --force`
3. Install mongodb using homebrew: `brew install mongodb`
4. Start mongodb and set it up to run unattended at boot:
  * For starting on reboot: `ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents/`
  * For starting immediately: `launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist`
5. Install [GPG](https://gpgtools.org)
6. Install [RVM](https://rvm.io/)
  * Make sure you install so ruby is included: `\curl -sSL https://get.rvm.io | bash -s stable --ruby`
7. Restart your terminal

Installation and Database Setup
===============================
1. Pull Cedar down from github: `git clone https://github.com/mitre/cedar`
2. Go into the new directory: `cd cedar`
3. Install the ruby bundler library: `gem install bundler`
4. Use the Gemfile to grab all the dependencies and install Cedar: `bundle install`
5. Seed the database: `bundle exec rake db:seed`
6. Follow the [Cypress bundle import instructions](https://github.com/projectcypress/cypress/wiki/Cypress-3.0.0-Install-Instructions#7-import-the-measure-bundle) to load the 2015 Measure Bundle
7. Start the background job worker: `bundle exec rake jobs:work`
8. In a separate shell, start the Cedar application: `bundle exec rake rails s`

Docker Installation
===================
TODO

Unit and System Tests
=====================
Currently, tests only exist for the `Cedar::Invalidator` module: `bundle exec rake test test/unit/lib/invalidator_test.rb`

Project Practices
=================
Cedar uses [rubocop](https://github.com/bbatsov/rubocop) to enforce consistent syntax.

License
=======
Copyright 2016 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

This project contains content developed by The MITRE Corporation. If this code is used in a deployment or embedded within another project, it is requested that you send an email to <mailto:opensource@mitre.org> in order to let us know where this software is being used.

MITRE
=====
[MITRE](https://www.mitre.org/) is a not-for-profit company that operates Federally Funded Research and Development Centers (FFRDC).

Cedar was initiated as part of the [CMS Alliance to Modernize Healthcare](https://www.mitre.org/centers/cms-alliances-to-modernize-healthcare/who-we-are) (CAMH) and strives to accelerate the [IHI's Triple AIM](http://www.ihi.org/Engage/Initiatives/TripleAim/Pages/default.aspx) of improved patient care, better population health, and reduced per capita cost in the United States healthcare system.
