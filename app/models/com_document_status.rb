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
  NOTHING = 0
  ACTIVE = 1
  ARCHIVED = 2
  DELETED = 3
  DRAFT = 4
  INACTIVE = 5
  LEGACY_NOTHING = 6
  PENDING = 7
  DEFAULTS = [NOTHING, ACTIVE, ARCHIVED, DELETED, DRAFT, INACTIVE, LEGACY_NOTHING, PENDING].freeze

  has_many :com_documents,
           foreign_key: :status_id,
           inverse_of: :com_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }

  def self.ensure_defaults!
    insert_missing_fixed_ids!(DEFAULTS)
  end
end
