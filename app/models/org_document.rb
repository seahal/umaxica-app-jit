# frozen_string_literal: true

# == Schema Information
#
# Table name: org_documents
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
#  index_org_documents_on_permalink                    (permalink) UNIQUE
#  index_org_documents_on_public_id                    (public_id)
#  index_org_documents_on_published_at_and_expires_at  (published_at,expires_at)
#  index_org_documents_on_status_id                    (status_id)
#

class OrgDocument < DocumentRecord
  include Document

  belongs_to :org_document_status,
             class_name: "OrgDocumentStatus",
             foreign_key: :status_id,
             inverse_of: :org_documents

  validates :status_id, length: { maximum: 255 }
  has_many :org_document_versions, dependent: :delete_all, inverse_of: :org_document
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

  def latest_version
    org_document_versions.order(created_at: :desc).first!
  end
end
