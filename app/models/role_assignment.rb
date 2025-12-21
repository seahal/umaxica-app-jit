# frozen_string_literal: true

# == Schema Information
#
# Table name: role_assignments
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  staff_id   :uuid
#  role_id    :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class RoleAssignment < IdentityRecord
  belongs_to :user, class_name: "User", optional: true, inverse_of: :role_assignments
  belongs_to :staff, class_name: "Staff", optional: true, inverse_of: :role_assignments
  belongs_to :role, inverse_of: :role_assignments
  has_one :organization, through: :role

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
