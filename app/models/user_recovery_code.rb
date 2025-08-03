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
# Indexes
#
#  index_user_recovery_codes_on_user_id  (user_id)
#
class UserRecoveryCode < IdentifiersRecord
  attr_accessor :confirm_create_recovery_code, :recovery_code

  validates :confirm_create_recovery_code, acceptance: true, on: :create

  before_save :set_recovery_code_digest, if: :recovery_code_changed?

  private

  def recovery_code_changed?
    recovery_code.present?
  end

  def set_recovery_code_digest
    require "digest"
    self.recovery_code_digest = Digest::SHA256.hexdigest(recovery_code)
  end
end
