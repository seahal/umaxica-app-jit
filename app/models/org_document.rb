# frozen_string_literal: true

# == Schema Information
#
# Table name: org_documents
# Database name: document
#
#  id            :uuid             not null, primary key
#  expires_at    :datetime         default(Infinity), not null
#  lock_version  :integer          default(0), not null
#  permalink     :string(200)      default(""), not null
#  position      :integer          default(0), not null
#  published_at  :datetime         default(Infinity), not null
#  redirect_url  :string
#  response_mode :string           default("html"), not null
#  revision_key  :string           default(""), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  slug_id       :string(32)       default(""), not null
#  status_id     :integer          default(0), not null
#
# Indexes
#
#  index_org_documents_on_permalink                    (permalink) UNIQUE
#  index_org_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_org_documents_on_slug_id                      (slug_id)
#  index_org_documents_on_status_id                    (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => org_document_statuses.id)
#

class OrgDocument < DocumentRecord
  include ::SlugId
  include Document

  belongs_to :org_document_status,
             class_name: "OrgDocumentStatus",
             foreign_key: :status_id,
             inverse_of: :org_documents

  belongs_to :latest_version_record,
             class_name: "OrgDocumentVersion",
             foreign_key: :latest_version_id,
             inverse_of: :latest_document,
             optional: true
  belongs_to :latest_revision_record,
             class_name: "OrgDocumentRevision",
             foreign_key: :latest_revision_id,
             inverse_of: :latest_document,
             optional: true

  has_many :org_document_versions, dependent: :delete_all, inverse_of: :org_document
  has_many :org_document_revisions, dependent: :delete_all, inverse_of: :org_document
  has_many :org_document_audits,
           #         -> { where(subject_type: "OrgDocument") },
           class_name: "OrgDocumentAudit",
           foreign_key: :subject_id,
           inverse_of: :org_document,
           dependent: :delete_all
  has_many :org_document_tags, dependent: :delete_all, inverse_of: :org_document
  has_many :tag_masters,
           through: :org_document_tags,
           source: :org_document_tag_master
  has_one :category,
          class_name: "OrgDocumentCategory",
          dependent: :delete,
          inverse_of: :org_document
  has_one :category_master,
          through: :category,
          source: :org_document_category_master
  validates :status_id, length: { maximum: 255 }

  def latest_version
    org_document_versions.order(created_at: :desc).first!
  end
end
