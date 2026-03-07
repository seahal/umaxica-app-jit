# typed: false
# == Schema Information
#
# Table name: staff_operators
# Database name: operator
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  operator_id :bigint           not null
#  staff_id    :bigint           not null
#
# Indexes
#
#  index_staff_operators_on_operator_id               (operator_id)
#  index_staff_operators_on_staff_id_and_operator_id  (staff_id,operator_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (operator_id => operators.id) ON DELETE => cascade
#  fk_rails_...  (staff_id => staffs.id) ON DELETE => cascade
#

# frozen_string_literal: true

class StaffOperator < OperatorRecord
  belongs_to :staff, inverse_of: :staff_operators
  belongs_to :operator, inverse_of: :staff_operators

  validates :operator_id, uniqueness: { scope: :staff_id }
end
