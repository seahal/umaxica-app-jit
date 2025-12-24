# == Schema Information
#
# Table name: com_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class ComDocumentStatus < BusinessesRecord
  include UppercaseId

  has_many :com_documents, dependent: :restrict_with_error, inverse_of: :com_document_status
end
