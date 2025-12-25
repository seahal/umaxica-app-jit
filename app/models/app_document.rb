# == Schema Information
#
# Table name: app_documents
#
#  id                     :uuid             not null, primary key
#  parent_id              :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  prev_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  succ_id                :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  title                  :string           default(""), not null
#  description            :string           default(""), not null
#  app_document_status_id :string(255)      default("NONE"), not null
#  staff_id               :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  public_id              :string(21)       default(""), not null
#
# Indexes
#
#  index_app_documents_on_app_document_status_id  (app_document_status_id)
#  index_app_documents_on_parent_id               (parent_id)
#  index_app_documents_on_prev_id                 (prev_id)
#  index_app_documents_on_public_id               (public_id)
#  index_app_documents_on_staff_id                (staff_id)
#  index_app_documents_on_succ_id                 (succ_id)
#

class AppDocument < BusinessesRecord
  include ::PublicId

  belongs_to :app_document_status, optional: true

  validates :app_document_status_id, length: { maximum: 255 }

  has_many :app_document_audits,
           class_name: "AppDocumentAudit",
           foreign_key: :subject_id,
           primary_key: "id",
           inverse_of: :app_document,
           dependent: :restrict_with_error

  encrypts :title
  encrypts :description
end
