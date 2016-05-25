Dir[File.dirname(__FILE__) + '/ext/*.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/cypress/cat_3_calculator.rb'].each { |file| require file }
Dir[File.dirname(__FILE__) + '/cypress/patient_zipper.rb'].each { |file| require file }
