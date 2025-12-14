# == Schema Information
#
# Table name: com_document_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ComDocumentStatus < BusinessesRecord
  has_many :com_documents, dependent: :restrict_with_error, inverse_of: :com_document_status

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/ }
end
