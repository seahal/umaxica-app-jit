# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
#
#  id :string           not null, primary key
#
class OrgDocumentStatus < BusinessesRecord
  include UppercaseId

  has_many :org_documents, dependent: :restrict_with_error, inverse_of: :org_document_status
end
