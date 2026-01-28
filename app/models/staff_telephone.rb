# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_telephones
# Database name: operator
#
#  id                                 :uuid             not null, primary key
#  locked_at                          :datetime         default(-Infinity), not null
#  number                             :string           default(""), not null
#  otp_attempts_count                 :integer          default(0), not null
#  otp_counter                        :text             default(""), not null
#  otp_expires_at                     :datetime         default(-Infinity), not null
#  otp_private_key                    :string           default(""), not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  staff_id                           :uuid             not null
#  staff_identity_telephone_status_id :string(255)      default("UNVERIFIED"), not null
#
# Indexes
#
#  index_staff_identity_telephones_on_lower_number               (lower((number)::text))
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
  include SetId

  MAX_TELEPHONES_PER_STAFF = 4

  belongs_to :staff_telephone_status, inverse_of: :staff_telephones, foreign_key: :staff_identity_telephone_status_id
  belongs_to :staff

  validates :number, presence: true, length: { maximum: 255 }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :staff_identity_telephone_status_id, length: { maximum: 255 }
  validate :enforce_staff_telephone_limit, on: :create
  before_validation do
    self.staff_id ||= "00000000-0000-0000-0000-000000000000"
  end

  after_initialize do
    self.number ||= ""
  end

  encrypts :number, deterministic: true

  private

    def enforce_staff_telephone_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_TELEPHONES_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum telephones per staff (#{MAX_TELEPHONES_PER_STAFF})")
    end
end
