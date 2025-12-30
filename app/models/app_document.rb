# frozen_string_literal: true

# == Schema Information
#
# Table name: app_documents
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  expires_at    :datetime         default("infinity"), not null
#  position      :integer          default(0), not null
#  public_id     :string(21)       default(""), not null
#  published_at  :datetime         default("infinity"), not null
#  redirect_url  :string
#  response_mode :string           default("html"), not null
#  status_id     :string(255)      default("NEYO"), not null
#  updated_at    :datetime         not null
#  permalink     :string(200)      default(""), not null
#  revision_key  :string           default(""), not null
#
# Indexes
#
#  index_app_documents_on_permalink                    (permalink) UNIQUE
#  index_app_documents_on_public_id                    (public_id)
#  index_app_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_app_documents_on_status_id                    (status_id)
#

class AppDocument < DocumentRecord
  include Document

  belongs_to :app_document_status,
             class_name: "AppDocumentStatus",
             foreign_key: :status_id,
             inverse_of: :app_documents

  validates :status_id, length: { maximum: 255 }

  has_many :app_document_versions, dependent: :delete_all, inverse_of: :app_document
  has_many :app_document_audits,
           #           -> { where(subject_type: "AppDocument") },
           class_name: "AppDocumentAudit",
           foreign_key: :subject_id,
           inverse_of: :app_document,
           dependent: :delete_all
  has_many :app_document_tags, dependent: :delete_all, inverse_of: :app_document
  has_many :tag_masters,
           through: :app_document_tags,
           source: :app_document_tag_master
  has_one :category,
          class_name: "AppDocumentCategory",
          dependent: :delete,
          inverse_of: :app_document
  has_one :category_master,
          through: :category,
          source: :app_document_category_master

  def latest_version
    app_document_versions.order(created_at: :desc).first!
  end
end
