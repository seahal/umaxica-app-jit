# == Schema Information
#
# Table name: staffs
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
require "test_helper"

class StaffTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
  end

  test "should be valid" do
    assert @staff.valid?
  end

  test "should have timestamps" do
    assert_not_nil @staff.created_at
    assert_not_nil @staff.updated_at
  end

  test "should have many emails association" do
    assert_respond_to @staff, :emails
    assert_equal "address", @staff.class.reflect_on_association(:emails).foreign_key
  end

  # test "should update timestamps on save" do
  #   original_updated_at = @staff.updated_at
  #   travel 1.second do
  #     @staff.touch
  #     assert @staff.updated_at > original_updated_at
  #   end
  # end
end
