# == Schema Information
#
# Table name: staff_identity_telephones
#
#  id                                 :uuid             not null, primary key
#  created_at                         :datetime         not null
#  locked_at                          :datetime         default("-infinity"), not null
#  number                             :string           default(""), not null
#  otp_attempts_count                 :integer          default(0), not null
#  otp_counter                        :text             default(""), not null
#  otp_expires_at                     :datetime         default("-infinity"), not null
#  otp_private_key                    :string           default(""), not null
#  staff_id                           :uuid             not null
#  staff_identity_telephone_status_id :string(255)      default("UNVERIFIED"), not null
#  updated_at                         :datetime         not null
#
# Indexes
#
#  idx_on_staff_identity_telephone_status_id_f2b1a32f7a  (staff_identity_telephone_status_id)
#  index_staff_identity_telephones_on_staff_id           (staff_id)
#

class StaffIdentityTelephone < IdentitiesRecord
  include Telephone
  include SetId

  MAX_TELEPHONES_PER_STAFF = 4

  belongs_to :staff_identity_telephone_status
  belongs_to :staff

  before_validation do
    self.staff_id ||= "00000000-0000-0000-0000-000000000000"
  end

  after_initialize do
    self.number ||= ""
  end

  encrypts :number, deterministic: true

  validates :number, presence: true, length: { maximum: 255 }
  validates :otp_attempts_count, presence: true, numericality: { only_integer: true }
  validates :otp_counter, presence: true
  validates :otp_private_key, presence: true, length: { maximum: 255 }
  validates :staff_identity_telephone_status_id, length: { maximum: 255 }

  validate :enforce_staff_telephone_limit, on: :create

  private

    def enforce_staff_telephone_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_TELEPHONES_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum telephones per staff (#{MAX_TELEPHONES_PER_STAFF})")
    end
end
