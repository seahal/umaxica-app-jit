# == Schema Information
#
# Table name: app_document_revisions
#
#  id              :uuid             not null, primary key
#  app_document_id :uuid             not null
#  permalink       :string(200)      not null
#  response_mode   :string           not null
#  redirect_url    :string
#  title           :string
#  description     :string
#  body            :text
#  published_at    :datetime         not null
#  expires_at      :datetime         not null
#  edited_by_type  :string
#  edited_by_id    :integer
#  public_id       :string(255)      default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_app_document_revisions_on_app_document_id                 (app_document_id)
#  index_app_document_revisions_on_app_document_id_and_created_at  (app_document_id,created_at)
#  index_app_document_revisions_on_public_id                       (public_id) UNIQUE
#

# frozen_string_literal: true

class AppDocumentRevision < DocumentRecord
  include ::Version
  include ::PublicId

  belongs_to :app_document, inverse_of: :app_document_revisions

  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
