# == Schema Information
#
# Table name: staffs
#
#  id              :binary           not null, primary key
#  otp_private_key :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
require "test_helper"

class StaffTest < ActiveSupport::TestCase
  def setup
    @staff = staffs(:one)
  end

  test "should be valid" do
    assert @staff.valid?
  end
  #
  # test "should inherit from IdentifiersRecord" do
  #   assert_instance_of IdentifiersRecord, @staff
  #   assert_kind_of IdentifiersRecord, @staff
  # end

  test "should have binary id" do
    assert @staff.id.is_a?(String)
    assert @staff.id.encoding == Encoding::ASCII_8BIT
  end

  test "should have timestamps" do
    assert_not_nil @staff.created_at
    assert_not_nil @staff.updated_at
  end

  test "should have otp_private_key attribute" do
    assert_respond_to @staff, :otp_private_key
    assert_respond_to @staff, :otp_private_key=
  end

  test "should allow nil otp_private_key" do
    @staff.otp_private_key = nil
    assert @staff.valid?
  end

  test "should allow string otp_private_key" do
    @staff.otp_private_key = "secret_key_12345"
    assert @staff.valid?
  end

  test "should have many emails association" do
    assert_respond_to @staff, :emails
    assert_equal "address", @staff.class.reflect_on_association(:emails).foreign_key
  end

  # test "should create staff with valid attributes" do
  #   staff = Staff.new
  #   assert staff.save
  #   assert_not_nil staff.id
  #   assert_not_nil staff.created_at
  #   assert_not_nil staff.updated_at
  # end

  # test "should create staff with otp_private_key" do
  #   staff = Staff.new(otp_private_key: "test_key_123")
  #   assert staff.save
  #   assert_equal "test_key_123", staff.otp_private_key
  # end

  test "should update timestamps on save" do
    original_updated_at = @staff.updated_at
    travel 1.second do
      @staff.touch
      assert @staff.updated_at > original_updated_at
    end
  end

  test "should handle otp_private_key updates" do
    original_key = @staff.otp_private_key
    new_key = "new_secret_key_67890"

    @staff.update(otp_private_key: new_key)
    @staff.reload

    assert_equal new_key, @staff.otp_private_key
    assert_not_equal original_key, @staff.otp_private_key
  end
end
