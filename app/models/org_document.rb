# == Schema Information
#
# Table name: org_documents
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  org_document_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class OrgDocument < BusinessesRecord
  include ::PublicId

  belongs_to :org_document_status, optional: true

  encrypts :title
  encrypts :description

  has_many :org_document_audits,
           class_name: "OrgDocumentAudit",
           primary_key: "id",
           inverse_of: :org_document,
           dependent: :restrict_with_error
end
