# == Schema Information
#
# Table name: staff_tokens
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :uuid
#
require "test_helper"

class StaffTokenTest < ActiveSupport::TestCase
  def setup
    @staff = Staff.create!
    @staff_token = StaffToken.new(staff_id: @staff.id)
  end

  test "should be valid" do
    assert_predicate @staff_token, :valid?
  end

  test "should have uuid as primary key" do
    @staff_token.save!

    assert_not_nil @staff_token.id
    assert_kind_of String, @staff_token.id
    assert_equal 36, @staff_token.id.length
  end

  test "should have created_at and updated_at timestamps" do
    @staff_token.save!

    assert_not_nil @staff_token.created_at
    assert_not_nil @staff_token.updated_at
  end

  test "should inherit from TokensRecord" do
    assert_equal TokensRecord, StaffToken.superclass
  end

  test "should be destroyable" do
    @staff_token.save!
    token_id = @staff_token.id
    @staff_token.destroy!

    assert_raises(ActiveRecord::RecordNotFound) do
      StaffToken.find(token_id)
    end
  end

  test "should handle mass assignment" do
    attributes = { staff_id: @staff.id }
    token = StaffToken.create!(attributes)

    assert_equal @staff.id, token.staff_id
  end

  test "should validate presence of required fields if implemented" do
    skip "TODO: add validation tests when validations are implemented"
  end

  test "should handle token expiration if implemented" do
    skip "TODO: add expiration tests when expiration logic is implemented"
  end

  test "should handle token scopes if implemented" do
    skip "TODO: add scope tests when scope functionality is implemented"
  end
end
