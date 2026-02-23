# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
# Database name: document
#
#  id :bigint           not null, primary key
#

class OrgDocumentStatus < DocumentRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  ARCHIVED = 2
  DELETED = 3
  DRAFT = 4
  INACTIVE = 5
  NEYO = 6
  PENDING = 7

  has_many :org_documents,
           foreign_key: :status_id,
           inverse_of: :org_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
