# == Schema Information
#
# Table name: staff_identity_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#  staff_identity_telephone_status_id :string
#
# Indexes
#
#  index_staff_identity_telephones_on_staff_id  (staff_id)
#  index_staff_identity_telephones_on_staff_identity_telephone_status_id  (staff_identity_telephone_status_id)
#
class StaffIdentityTelephone < IdentitiesRecord
  include Telephone
  include SetId

  MAX_TELEPHONES_PER_STAFF = 4

  belongs_to :staff_identity_telephone_status, optional: true
  belongs_to :staff, optional: true

  encrypts :number, deterministic: true

  validate :enforce_staff_telephone_limit, on: :create

  private

    def enforce_staff_telephone_limit
      return unless staff_id

      count = self.class.where(staff_id: staff_id).count
      return if count < MAX_TELEPHONES_PER_STAFF

      errors.add(:base, :too_many, message: "exceeds maximum telephones per staff (#{MAX_TELEPHONES_PER_STAFF})")
    end
end
