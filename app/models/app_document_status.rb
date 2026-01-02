# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class AppDocumentStatus < DocumentRecord
  include UppercaseId

  has_many :app_documents,
           foreign_key: :status_id,
           inverse_of: :app_document_status,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
