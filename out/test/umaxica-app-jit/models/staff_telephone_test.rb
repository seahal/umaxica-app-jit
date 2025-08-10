# == Schema Information
#
# Table name: staff_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#
# Indexes
#
#  index_staff_telephones_on_staff_id  (staff_id)
#
require "test_helper"

class StaffTelephoneTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
