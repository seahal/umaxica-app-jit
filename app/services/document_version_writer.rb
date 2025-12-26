# frozen_string_literal: true

class DocumentVersionWriter
  def self.write!(document, attrs:, editor: nil)
    version_class, document_key = case document
    when ComDocument then [ComDocumentVersion, :com_document]
    when AppDocument then [AppDocumentVersion, :app_document]
    when OrgDocument then [OrgDocumentVersion, :org_document]
    else
      raise ArgumentError, "unsupported document type: #{document.class}"
    end

    version_class.create!(
      document_key => document,
      :permalink => document.permalink,
      :response_mode => document.response_mode,
      :redirect_url => document.redirect_url,
      :published_at => document.published_at,
      :expires_at => document.expires_at,
      :title => attrs[:title],
      :description => attrs[:description],
      :body => attrs[:body],
      :edited_by_type => editor&.class&.name,
      :edited_by_id => editor&.id,
    )
  end
end
