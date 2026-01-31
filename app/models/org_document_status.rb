# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
# Database name: document
#
#  id :integer          default(0), not null, primary key
#

class OrgDocumentStatus < DocumentRecord
  include StringPrimaryKey

  has_many :org_documents,
           foreign_key: :status_id,
           inverse_of: :org_document_status,
           dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
