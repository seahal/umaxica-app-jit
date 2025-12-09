# == Schema Information
#
# Table name: app_document_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class AppDocumentStatus < BusinessesRecord
  has_many :app_documents, dependent: :restrict_with_error, inverse_of: :app_document_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
