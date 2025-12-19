# frozen_string_literal: true

# == Schema Information
#
# Table name: com_document_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ComDocumentStatus < BusinessesRecord
  include UppercaseId

  has_many :com_documents, dependent: :restrict_with_error, inverse_of: :com_document_status
end
