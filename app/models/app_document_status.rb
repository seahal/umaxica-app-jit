# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_statuses
# Database name: document
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_app_document_statuses_on_code  (code) UNIQUE
#

class AppDocumentStatus < DocumentRecord
  include CodeIdentifiable

  has_many :app_documents,
           foreign_key: :status_id,
           inverse_of: :app_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
