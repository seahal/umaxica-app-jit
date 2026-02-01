# == Schema Information
#
# Table name: org_document_revisions
# Database name: document
#
#  id              :bigint           not null, primary key
#  body            :text
#  description     :string
#  edited_by_type  :string
#  expires_at      :datetime         not null
#  permalink       :string(200)      not null
#  published_at    :datetime         not null
#  redirect_url    :string
#  response_mode   :string           not null
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  edited_by_id    :bigint
#  org_document_id :bigint           not null
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_org_document_revisions_on_org_document_id                 (org_document_id)
#  index_org_document_revisions_on_org_document_id_and_created_at  (org_document_id,created_at)
#  index_org_document_revisions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (org_document_id => org_documents.id)
#

# frozen_string_literal: true

class OrgDocumentRevision < DocumentRecord
  include ::Version
  include ::PublicId

  belongs_to :org_document, inverse_of: :org_document_revisions
  has_one :latest_document,
          class_name: "OrgDocument",
          foreign_key: :latest_revision_id,
          dependent: :nullify,
          inverse_of: :latest_revision_record

  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
