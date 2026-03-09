# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephones
# Database name: operator
#
#  id                                 :bigint           not null, primary key
#  locked_at                          :datetime
#  number                             :string           not null
#  otp_attempts_count                 :integer          default(0), not null
#  otp_counter                        :text             not null
#  otp_expires_at                     :datetime
#  otp_private_key                    :string           not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  staff_id                           :bigint           not null
#  staff_identity_telephone_status_id :bigint           default(6), not null
#
# Indexes
#
#  index_staff_telephones_on_lower_number                        (lower((number)::text)) UNIQUE
#  index_staff_telephones_on_staff_id                            (staff_id)
#  index_staff_telephones_on_staff_identity_telephone_status_id  (staff_identity_telephone_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (staff_id => staffs.id)
#  fk_rails_...  (staff_identity_telephone_status_id => staff_telephone_statuses.id)
#

class StaffTelephone < OperatorRecord
  alias_attribute :staff_telephone_status_id, :staff_identity_telephone_status_id
  include Telephone

  self.filter_attributes += %w(number)

  MAX_TELEPHONES_PER_STAFF = 4
  attribute :staff_identity_telephone_status_id, default: StaffTelephoneStatus::UNVERIFIED

  belongs_to :staff_telephone_status, inverse_of: :staff_telephones, foreign_key: :staff_identity_telephone_status_id
  belongs_to :staff

  # Note: :number validation is now handled by Telephone concern (E.164 normalization)
  validates :number, presence: true, uniqueness: { case_sensitive: false }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :staff_identity_telephone_status_id, numericality: { only_integer: true }
  validate :enforce_staff_telephone_limit, on: :create
  before_validation do
    self.staff_id ||= "00000000-0000-0000-0000-000000000000"
  end

  after_initialize do
    self.number ||= ""
  end

  # Note: :number encryption is handled by Telephone concern

  private

  def enforce_staff_telephone_limit
    return unless staff_id

    count = self.class.where(staff_id: staff_id).count
    return if count < MAX_TELEPHONES_PER_STAFF

    errors.add(:base, :too_many, message: "exceeds maximum telephones per staff (#{MAX_TELEPHONES_PER_STAFF})")
  end
end
