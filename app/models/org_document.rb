# == Schema Information
#
# Table name: org_documents
#
#  id                     :uuid             not null, primary key
#  created_at             :datetime         not null
#  description            :string           default(""), not null
#  org_document_status_id :string(255)      default(""), not null
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  public_id              :string(21)       default(""), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_org_documents_on_org_document_status_id  (org_document_status_id)
#  index_org_documents_on_parent_id               (parent_id)
#  index_org_documents_on_prev_id                 (prev_id)
#  index_org_documents_on_public_id               (public_id)
#  index_org_documents_on_staff_id                (staff_id)
#  index_org_documents_on_succ_id                 (succ_id)
#

class OrgDocument < BusinessesRecord
  include ::PublicId

  belongs_to :org_document_status, optional: true

  validates :org_document_status_id, length: { maximum: 255 }

  encrypts :title
  encrypts :description

  has_many :org_document_audits,
           class_name: "OrgDocumentAudit",
           primary_key: "id",
           inverse_of: :org_document,
           dependent: :restrict_with_error
end
