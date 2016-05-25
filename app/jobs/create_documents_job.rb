class CreateDocumentsJob < ActiveJob::Base
  queue_as :default

  def perform(te)
    te.create_documents
  end
end
