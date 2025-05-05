# == Schema Information
#
# Table name: user_recovery_codes
#
#  id              :bigint           not null, primary key
#  expire_in       :date
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class UserRecoveryCode < IdentifiersRecord
  attr_accessor :password, :comfirm_create_recovery_code
  validates :password,
            length: { is: 16 },
            format: { with: /\A[ABCDEFHIJKMNOPRSTWXY2347]+\z/ }
  validates :confirm_create_recovery_code, acceptance: true, on: :create
end
