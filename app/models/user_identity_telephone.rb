# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_telephones
#
#  id                                :uuid             not null, primary key
#  created_at                        :datetime         not null
#  locked_at                         :datetime         default("-infinity"), not null
#  number                            :string           default(""), not null
#  otp_attempts_count                :integer          default(0), not null
#  otp_counter                       :text             default(""), not null
#  otp_expires_at                    :datetime         default("-infinity"), not null
#  otp_private_key                   :string           default(""), not null
#  updated_at                        :datetime         not null
#  user_id                           :uuid             not null
#  user_identity_telephone_status_id :string(255)      default("UNVERIFIED"), not null
#
# Indexes
#
#  idx_on_user_identity_telephone_status_id_a15207191e  (user_identity_telephone_status_id)
#  index_user_identity_telephones_on_user_id            (user_id)
#

class UserIdentityTelephone < IdentitiesRecord
  include Telephone
  include SetId
  include Turnstile

  MAX_TELEPHONES_PER_USER = 4

  belongs_to :user_identity_telephone_status
  belongs_to :user, inverse_of: :user_identity_telephones

  before_validation do
    self.user_id ||= "00000000-0000-0000-0000-000000000000"
  end

  after_initialize do
    self.number ||= ""
  end

  encrypts :number, deterministic: true

  validates :number, presence: true, length: { maximum: 255 }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :user_identity_telephone_status_id, length: { maximum: 255 }

  validate :enforce_user_telephone_limit, on: :create

  private

  def enforce_user_telephone_limit
    return unless user_id

    count = self.class.where(user_id: user_id).count
    return if count < MAX_TELEPHONES_PER_USER

    errors.add(:base, :too_many, message: "exceeds maximum telephones per user (#{MAX_TELEPHONES_PER_USER})")
  end
end
