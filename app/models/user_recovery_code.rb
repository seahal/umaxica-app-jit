# == Schema Information
#
# Table name: user_recovery_codes
#
#  id                   :uuid             not null, primary key
#  expires_in           :date
#  recovery_code_digest :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
class UserRecoveryCode < IdentitiesRecord
  belongs_to :user

  attr_accessor :confirm_create_recovery_code

  validates :recovery_code_digest, presence: true
end
