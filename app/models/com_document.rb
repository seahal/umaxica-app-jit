# frozen_string_literal: true

# == Schema Information
#
# Table name: com_documents
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
#  index_com_documents_on_permalink                    (permalink) UNIQUE
#  index_com_documents_on_public_id                    (public_id)
#  index_com_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_com_documents_on_status_id                    (status_id)
#

class ComDocument < DocumentRecord
  include Document

  belongs_to :com_document_status,
             class_name: "ComDocumentStatus",
             foreign_key: :status_id,
             inverse_of: :com_documents

  validates :status_id, length: { maximum: 255 }
  has_many :com_document_versions, dependent: :delete_all, inverse_of: :com_document
  has_many :com_document_audits,
           #           -> { where(subject_type: "ComDocument") },
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

  def latest_version
    com_document_versions.order(created_at: :desc).first!
  end
end
