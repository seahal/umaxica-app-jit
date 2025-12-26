# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_one_time_passwords
#
#  user_id                                   :binary           not null
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  private_key                               :string(1024)     default(""), not null
#  last_otp_at                               :datetime         default("-infinity"), not null
#  user_identity_one_time_password_status_id :string           default("NONE"), not null
#  id                                        :uuid             not null, primary key
#
# Indexes
#
#  idx_on_user_identity_one_time_password_status_id_01264db86c  (user_identity_one_time_password_status_id)
#

class UserIdentityOneTimePassword < IdentitiesRecord
  MAX_TOTPS_PER_USER = 2

  belongs_to :user
  belongs_to :user_identity_one_time_password_status, optional: true, inverse_of: :user_identity_one_time_passwords

  attr_accessor :first_token

  validates :private_key, presence: true, length: { maximum: 1024 }
  validates :last_otp_at, presence: true
  validate :enforce_user_totp_limit, on: :create

  after_initialize :generate_private_key_if_blank

  private

  def enforce_user_totp_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_TOTPS_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum totps per user (#{MAX_TOTPS_PER_USER})")
  end

  def generate_private_key_if_blank
    self.private_key = ROTP::Base32.random_base32 if private_key.blank?
  end
end
