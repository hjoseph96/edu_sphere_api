Rails.configuration.to_prepare do
  ActiveStorage::Blob.class_eval do
    before_create :generate_key_with_prefix

    def generate_key_with_prefix
      self.key = File.join prefix, self.class.generate_unique_secure_token
    end

    def prefix
      case Rails.env
          when 'development' then 'dev'
          when 'staging' then 'stage'
          when 'production' then 'prod'
      end
    end
  end

  module ActiveStorage::Attachment::Callbacks
    extend ActiveSupport::Concern
  
    prepended do
      after_commit :attachment_created, on: :create
      after_commit :attachment_changed, on: :update
      after_commit :attachment_destroyed, on: :destroy
    end
  
    def attachment_changed
      record.after_attachment_update(self) if record.respond_to?(:after_attachment_update)
    end

    def attachment_created
      record.after_attachment_create(self) if record.respond_to?(:after_attachment_create)
    end

    def attachment_destroyed
      record.after_attachment_destroy(self) if record.respond_to?(:after_attachment_destroy)
    end
  end
  
  ActiveStorage::Attachment.prepend ActiveStorage::Attachment::Callbacks
end