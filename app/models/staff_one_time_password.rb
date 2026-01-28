# == Schema Information
#
# Table name: staff_one_time_passwords
# Database name: operator
#
#  id                                :uuid             not null, primary key
#  last_otp_at                       :datetime         default(-Infinity), not null
#  private_key                       :string(1024)     default(""), not null
#  title                             :string(32)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  public_id                         :string(21)
#  staff_id                          :uuid             not null
#  staff_one_time_password_status_id :string           default("NEYO"), not null
#
# Indexes
#
#  idx_on_staff_one_time_password_status_id_8958a1c9bf  (staff_one_time_password_status_id)
#  index_staff_one_time_passwords_on_public_id          (public_id) UNIQUE
#  index_staff_one_time_passwords_on_staff_id           (staff_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_one_time_password_status_id => staff_one_time_password_statuses.id)
#

# frozen_string_literal: true

class StaffOneTimePassword < OperatorRecord
  include ::PublicId

  MAX_TOTPS_PER_STAFF = 2

  attr_accessor :first_token

  belongs_to :staff, inverse_of: :staff_one_time_passwords
  belongs_to :staff_one_time_password_status, optional: true

  attribute :staff_one_time_password_status_id, default: "NEYO"

  validates :private_key, presence: true, length: { maximum: 1024 }
  validates :last_otp_at, presence: true
  validates :title, length: { maximum: 32 }, allow_blank: true
  validate :enforce_staff_totp_limit, on: :create

  after_initialize :generate_private_key_if_blank
  after_initialize :generate_public_id_if_blank

  private

    def generate_public_id_if_blank
      return unless has_attribute?(:public_id)

      self.public_id = Nanoid.generate(size: 21) if self[:public_id].blank?
    end

    def enforce_staff_totp_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_TOTPS_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum totps per staff (#{MAX_TOTPS_PER_STAFF})")
    end

    def generate_private_key_if_blank
      self.private_key = ROTP::Base32.random_base32 if private_key.blank?
    end
end
