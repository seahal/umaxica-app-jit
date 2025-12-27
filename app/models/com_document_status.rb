# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_statuses
#
#  id :string(255)      default("NONE"), not null, primary key
#

class ComDocumentStatus < DocumentRecord
  include UppercaseId

  has_many :com_documents,
           foreign_key: :status_id,
           inverse_of: :com_document_status,
           dependent: :restrict_with_error
end
