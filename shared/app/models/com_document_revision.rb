# typed: false
# == Schema Information
#
# Table name: com_document_revisions
# Database name: publication
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
#  com_document_id :bigint           not null
#  edited_by_id    :bigint
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_com_document_revisions_on_com_document_id_and_created_at  (com_document_id,created_at)
#  index_com_document_revisions_on_edited_by_id                    (edited_by_id)
#  index_com_document_revisions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (com_document_id => com_documents.id)
#

# frozen_string_literal: true

class ComDocumentRevision < PublicationRecord
  include ::Version
  include ::PublicId

  belongs_to :com_document, inverse_of: :com_document_revisions
  has_one :latest_document,
          class_name: "ComDocument",
          foreign_key: :latest_revision_id,
          dependent: :nullify,
          inverse_of: :latest_revision_record

  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
