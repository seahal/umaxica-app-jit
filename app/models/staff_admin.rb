# == Schema Information
#
# Table name: staff_admins
#
#  id         :uuid             not null, primary key
#  staff_id   :uuid             not null
#  admin_id   :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_staff_admins_on_admin_id               (admin_id)
#  index_staff_admins_on_staff_id_and_admin_id  (staff_id,admin_id) UNIQUE
#

# frozen_string_literal: true

class StaffAdmin < IdentitiesRecord
  self.implicit_order_column = :created_at
  belongs_to :staff
  belongs_to :admin

  validates :admin_id, uniqueness: { scope: :staff_id }
end
