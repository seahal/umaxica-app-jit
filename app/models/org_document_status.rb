# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
# Database name: document
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_org_document_statuses_on_code  (code) UNIQUE
#

class OrgDocumentStatus < DocumentRecord
  include CodeIdentifiable

  has_many :org_documents,
           foreign_key: :status_id,
           inverse_of: :org_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
