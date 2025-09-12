# frozen_string_literal: true

class UploadMarkdownJob
  include Sidekiq::Job

  def perform(document_id)
    document = Document.find(document_id)
    document.upload_markdown
  end
end
