# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class OrgDocumentStatus < DocumentRecord
  include UppercaseId

  has_many :org_documents,
           foreign_key: :status_id,
           inverse_of: :org_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
