# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_statuses
# Database name: document
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_document_statuses_on_code  (code) UNIQUE
#

class ComDocumentStatus < DocumentRecord
  include CodeIdentifiable

  has_many :com_documents,
           foreign_key: :status_id,
           inverse_of: :com_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
