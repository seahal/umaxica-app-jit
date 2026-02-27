# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_versions
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
#  app_document_id :bigint           not null
#  edited_by_id    :bigint
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_app_document_versions_on_app_document_id_and_created_at  (app_document_id,created_at)
#  index_app_document_versions_on_edited_by_id                    (edited_by_id)
#  index_app_document_versions_on_public_id                       (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (app_document_id => app_documents.id) ON DELETE => cascade
#

class AppDocumentVersion < DocumentRecord
  include ::Version
  include ::PublicId

  belongs_to :app_document, inverse_of: :app_document_versions
  has_one :latest_document,
          class_name: "AppDocument",
          foreign_key: :latest_version_id,
          dependent: :nullify,
          inverse_of: :latest_version_record

  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
