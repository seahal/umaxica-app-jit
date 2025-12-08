class StaffIdentityStatus < IdentitiesRecord
  has_many :staffs, foreign_key: :staff_status_id, dependent: :restrict_with_error, inverse_of: :staff_identity_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
