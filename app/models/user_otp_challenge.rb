# frozen_string_literal: true

# == Schema Information
#
# Table name: user_otp_challenges
#
#  id               :uuid             not null, primary key
#  user_id          :uuid             not null
#  address          :string           not null
#  otp_private_key  :string           not null
#  otp_counter      :bigint           not null
#  expires_at       :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class UserOtpChallenge < IdentitiesRecord
  belongs_to :user, optional: true

  # Automatically delete expired challenges
  scope :active, -> { where("expires_at > ?", Time.current) }
  scope :expired, -> { where(expires_at: ..Time.current) }

  # Clean up expired challenges (call periodically)
  def self.cleanup_expired
    expired.delete_all
  end

  # Check if this challenge is still valid
  def active?
    expires_at > Time.current
  end

  # Check if this challenge has expired
  def expired?
    !active?
  end
end
