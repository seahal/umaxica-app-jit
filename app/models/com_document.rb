# frozen_string_literal: true

# == Schema Information
#
# Table name: com_documents
# Database name: document
#
#  id            :bigint           not null, primary key
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
#  index_com_documents_on_permalink                    (permalink) UNIQUE
#  index_com_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_com_documents_on_slug_id                      (slug_id)
#  index_com_documents_on_status_id                    (status_id)
#
# Foreign Keys
#
#  fk_rails_...  (status_id => com_document_statuses.id)
#

class ComDocument < DocumentRecord
  include ::SlugId
  include Document

  belongs_to :com_document_status,
             class_name: "ComDocumentStatus",
             foreign_key: :status_id,
             inverse_of: :com_documents

  belongs_to :latest_version_record,
             class_name: "ComDocumentVersion",
             foreign_key: :latest_version_id,
             inverse_of: :latest_document,
             optional: true
  belongs_to :latest_revision_record,
             class_name: "ComDocumentRevision",
             foreign_key: :latest_revision_id,
             inverse_of: :latest_document,
             optional: true

  has_many :com_document_versions, dependent: :delete_all, inverse_of: :com_document
  has_many :com_document_revisions, dependent: :delete_all, inverse_of: :com_document
  has_many :com_document_audits,
           class_name: "ComDocumentAudit",
           foreign_key: :subject_id,
           inverse_of: :com_document,
           dependent: :delete_all
  has_many :com_document_tags, dependent: :delete_all, inverse_of: :com_document
  has_many :tag_masters,
           through: :com_document_tags,
           source: :com_document_tag_master
  has_one :category,
          class_name: "ComDocumentCategory",
          dependent: :delete,
          inverse_of: :com_document
  has_one :category_master,
          through: :category,
          source: :com_document_category_master
  validates :status_id, length: { maximum: 255 }

  def latest_version
    com_document_versions.order(created_at: :desc).first!
  end
end
