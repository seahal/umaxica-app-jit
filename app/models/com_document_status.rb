# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_statuses
# Database name: document
#
#  id :bigint           not null, primary key
#

class ComDocumentStatus < DocumentRecord
  # Fixed IDs - do not modify these values
  ACTIVE = 1
  ARCHIVED = 2
  DELETED = 3
  DRAFT = 4
  INACTIVE = 5
  NOTHING = 6 # FIXME: set 0 as null value
  PENDING = 7

  has_many :com_documents,
           foreign_key: :status_id,
           inverse_of: :com_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
