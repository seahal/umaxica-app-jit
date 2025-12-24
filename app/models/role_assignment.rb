# == Schema Information
#
# Table name: role_assignments
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  role_id    :uuid             not null
#  staff_id   :uuid
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_role_assignments_on_role_id     (role_id)
#  index_role_assignments_on_staff_role  (staff_id,role_id) UNIQUE
#  index_role_assignments_on_user_role   (user_id,role_id) UNIQUE
#

class RoleAssignment < IdentityRecord
  belongs_to :user, class_name: "User", optional: true, inverse_of: :role_assignments
  belongs_to :staff, class_name: "Staff", optional: true, inverse_of: :role_assignments
  belongs_to :role, inverse_of: :role_assignments
  has_one :organization, through: :role
  validates :role_id, uniqueness: { scope: :staff_id }, if: -> { staff_id.present? }
  validates :role_id, uniqueness: { scope: :user_id }, if: -> { user_id.present? }

  validate :user_or_staff_present
  validate :user_and_staff_exclusive

  private

    def user_or_staff_present
      errors.add(:base, "Either user_id or staff_id must be present") if user_id.blank? && staff_id.blank?
    end

    def user_and_staff_exclusive
      errors.add(:base, "Cannot assign to both user and staff") if user_id.present? && staff_id.present?
    end
end
