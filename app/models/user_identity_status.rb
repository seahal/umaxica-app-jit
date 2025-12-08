class UserIdentityStatus < IdentitiesRecord
  has_many :users, dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: true
end
