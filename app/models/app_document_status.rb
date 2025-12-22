# == Schema Information
#
# Table name: app_document_statuses
#
#  id :string           not null, primary key
#
class AppDocumentStatus < BusinessesRecord
  include UppercaseId

  has_many :app_documents, dependent: :restrict_with_error, inverse_of: :app_document_status
end
