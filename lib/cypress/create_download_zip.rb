module Cypress
  class CreateDownloadZip
    # def self.create_test_zip(test_id, format = 'html')
    #   pt = ProductTest.find(test_id)
    #   create_zip(pt.records.to_a, format)
    # end

    def self.create_zip(patients, format, measure, start_date, end_date)
      file = Tempfile.new("patients-#{Time.now.to_i}")
      Cypress::PatientZipper.zip(file, patients, format, measure, start_date, end_date)
      file
    end

    # def self.create_total_test_zip(product, format = 'qrda')
    #   measure_tests = MeasureTest.where(product_id: product.id)
    #   file = Tempfile.new("all-patients-#{Time.now.to_i}")
    #   Zip::ZipOutputStream.open(file.path) do |z|
    #     measure_tests.each do |m|
    #       z.put_next_entry("#{m.cms_id}_#{m.id}.#{format}.zip".tr(' ', '_'))
    #       z << m.patient_archive.read
    #     end
    #   end
    #   file
    # end
  end
end
