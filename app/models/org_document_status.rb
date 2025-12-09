# == Schema Information
#
# Table name: org_document_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class OrgDocumentStatus < BusinessesRecord
  has_many :org_documents, dependent: :restrict_with_error, inverse_of: :org_document_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
