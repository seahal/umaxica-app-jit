# == Schema Information
#
# Table name: app_documents
#
#  id               :uuid             not null, primary key
#  description      :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  app_document_status_id :string
#  parent_id        :uuid
#  prev_id          :uuid
#  staff_id         :uuid
#  succ_id          :uuid
#
class AppDocument < BusinessesRecord
  include ::PublicId

  belongs_to :app_document_status, optional: true

  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           primary_key: "id",
           inverse_of: :app_document,
           dependent: :restrict_with_exception

  encrypts :title
  encrypts :description
end
