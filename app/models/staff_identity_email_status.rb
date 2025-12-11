class StaffIdentityEmailStatus < IdentitiesRecord
  has_many :staff_identity_emails, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true

  # Status constants
  UNVERIFIED = "UNVERIFIED"
  VERIFIED = "VERIFIED"
  SUSPENDED = "SUSPENDED"
  DELETED = "DELETED"
end
