# == Schema Information
#
# Table name: staff_telephones
#
#  id         :binary           not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

class StaffTelephoneTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
