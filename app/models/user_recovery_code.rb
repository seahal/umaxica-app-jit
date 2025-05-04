class UserRecoveryCode < IdentifiersRecord
  attr_accessor :password
  validates :password,
            length: { is: 16 },
            format: { with: /\A[ABCDEFHIJKMNOPRSTWXY2347]+\z/ }
end
