# typed: false
# frozen_string_literal: true

require "test_helper"

class UnchangedValidatorTest < ActiveSupport::TestCase
  setup do
    [0, 1, 2, 3].each { |id| UserVisibility.find_or_create_by!(id: id) }
  end

  test "unchanged validator allows creation with public_id" do
    # User uses PublicId concern which auto-generates public_id
    user = User.new(status_id: UserStatus::NOTHING)

    assert_predicate user, :valid?
    assert_not_nil user.public_id
  end

  test "unchanged validator allows update when public_id unchanged" do
    user = User.create!(status_id: UserStatus::NOTHING)

    user.status_id = UserStatus::RESERVED

    assert_predicate user, :valid?
  end

  test "unchanged validator rejects update when public_id changed" do
    user = User.create!(status_id: UserStatus::NOTHING)

    # Stub will_save_change_to_attribute? to simulate public_id change
    user.stub(:will_save_change_to_attribute?, ->(attr) { attr == :public_id }) do
      assert_not_predicate user, :valid?
      assert_includes user.errors[:public_id], "cannot be changed"
    end
  end
end
