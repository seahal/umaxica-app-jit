# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_versions
#
#  id              :uuid             not null, primary key
#  com_document_id :uuid             not null
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
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  public_id       :string(255)      default(""), not null
#
# Indexes
#
#  index_com_document_versions_on_com_document_id_and_created_at  (com_document_id,created_at)
#  index_com_document_versions_on_public_id                       (public_id) UNIQUE
#

class ComDocumentVersion < DocumentRecord
  include Version
  include ::PublicId

  belongs_to :com_document

  validates :permalink, presence: true, length: { maximum: 200 }
  validates :response_mode, presence: true
  validates :published_at, presence: true
  validates :expires_at, presence: true
end
