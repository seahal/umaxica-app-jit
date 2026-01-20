# frozen_string_literal: true

# == Schema Information
#
# Table name: app_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class AppDocumentStatus < DocumentRecord
  include StringPrimaryKey

  has_many :app_documents,
           foreign_key: :status_id,
           inverse_of: :app_document_status,
           dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
