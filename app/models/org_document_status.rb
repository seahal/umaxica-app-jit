# frozen_string_literal: true

# == Schema Information
#
# Table name: org_document_statuses
# Database name: document
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_org_document_statuses_on_lower_id  (lower((id)::text)) UNIQUE
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
