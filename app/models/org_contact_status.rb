class OrgContactStatus < GuestsRecord
  self.primary_key = :title

  has_many :org_contacts,
           foreign_key: :contact_status_title,
           inverse_of: :org_contact_status,
           dependent: :nullify

  before_validation { self.title = title&.upcase }
  validates :title, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false }, format: { with: /\A[A-Z0-9_]+\z/ }
end
