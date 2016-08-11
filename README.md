Cedar
=====
Cedar is a tool for testing the strength of Electronic Clinical Quality Measure (eCQM) collection systems that receive Quality Reporting Document Architecture (QRDA) files. The Cedar tool is open source and freely available for use or adoption by state health agencies or any other organization that is set up to receive QRDA files.

To report a software bug, submit a feature request, or leave usability feedback, please use the [Cedar issue tracker](https://github.com/mitre/cedar/issues).  For all other questions, comments, or concerns, email <mailto:cedar-feedback-list@lists.mitre.org>.

Technical Architecture
======================
Cedar is a Ruby on Rails application with a mongo database backend.  Wherever possible, Cedar attempts to conform to rails conventions.

**Note: below you will find instructions for using Cedar on unix-based systems.  A windows-based version of Cedar is planned, but is not currently available**

Local Development Installation
==============================
To start a local instance of Cedar for development purposes, ensure that you have done the following:

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
8. Pull Cedar down from github: `git clone https://github.com/mitre/cedar`
9. Go into the new directory: `cd cedar`
10. Install the ruby bundler library: `gem install bundler`
11. Use the Gemfile to grab all the dependencies and install Cedar: `bundle install`
12. Import Cypress measure bundles (containing seed information for measures, patients, value sets, etc.): `./bundle_import.sh`
  - Note: you will be asked multiple times for an NLM username and password. If you do not have one, you may [request an NLM username and password](https://uts.nlm.nih.gov/home.html) (also referred to as a UMLS license).
13. Start the background job worker: `bundle exec rake jobs:work`
14. In a separate shell, start the Cedar application: `bundle exec rails s`

Production Docker Installation
==============================
**Note: if you are running docker on OSX or Windows, make sure that you have installed a version >= 1.12.0, as this allows for containers to run without docker-machine.**

1. Pull Cedar down from github: `git clone https://github.com/mitre/cedar`
2. Go into the new directory: `cd cedar`
3. Generate new secrets for devise and rails: `./prod_setup.sh`
4. Build and start the docker image: `docker-compose build && docker-compose up`
5. In a separate terminal window, start the Cedar application: `docker-compose run cedar`
6. In yet another terminal window, download the 2014, 2015, and 2016 Measure Bundles and import them:
  * `docker exec -it cedar_cedar_1 ./bin/bundle exec rake bundle:download_and_install version=2015-alpha-20160224`
  * You will be prompted for your [NLM username and password](https://www.nlm.nih.gov/databases/umls.html)
  * Repeat with `version=2.6.0` and `version=2.4.0`
7. You should be able to use Cedar running at `http://localhost:3000`

API
===
API documentation is located at `http://localhost:3000/apidocs`

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
