class StaffIdentityStatus < IdentitiesRecord
  # Use Rails convention `staff_identity_status_id` as the foreign key on `staffs`.
  has_many :staffs, dependent: :restrict_with_error, inverse_of: :staff_identity_status

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
