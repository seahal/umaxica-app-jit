# frozen_string_literal: true

class OrgDocumentUpdater
  def self.call(document:, attrs:, editor: nil)
    DocumentRecord.transaction do
      document.update!(document_attributes(attrs))
      DocumentVersionWriter.write!(document, attrs: attrs, editor: editor)
    end
  end

  def self.document_attributes(attrs)
    attrs.slice(:permalink, :response_mode, :redirect_url, :published_at, :expires_at, :position)
  end
  private_class_method :document_attributes
end
