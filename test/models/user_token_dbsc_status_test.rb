# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: user_token_dbsc_statuses
# Database name: token
#
#  id :bigint           not null, primary key
#
require "test_helper"

class UserTokenDbscStatusTest < ActiveSupport::TestCase
  def setup
    # Use find_or_create_by instead of delete_all to avoid FK violations
    UserTokenDbscStatus::DEFAULTS.each do |id|
      UserTokenDbscStatus.find_or_create_by!(id: id)
    end
  end

  test "NOTHING constant is defined" do
    assert_equal 0, UserTokenDbscStatus::NOTHING
  end

  test "PENDING constant is defined" do
    assert_equal 1, UserTokenDbscStatus::PENDING
  end

  test "ACTIVE constant is defined" do
    assert_equal 2, UserTokenDbscStatus::ACTIVE
  end

  test "FAILED constant is defined" do
    assert_equal 3, UserTokenDbscStatus::FAILED
  end

  test "REVOKE constant is defined" do
    assert_equal 4, UserTokenDbscStatus::REVOKE
  end

  test "DEFAULTS constant contains all status values" do
    expected = [0, 1, 2, 3, 4]

    assert_equal expected, UserTokenDbscStatus::DEFAULTS
  end

  test "has_many user_tokens association" do
    assert_respond_to UserTokenDbscStatus.new, :user_tokens
  end

  test "ensure_defaults! creates missing status records" do
    UserTokenDbscStatus.count

    # Delete one record to test creation
    UserTokenDbscStatus.where(id: UserTokenDbscStatus::REVOKE).destroy_all

    assert_difference("UserTokenDbscStatus.count", 1) do
      UserTokenDbscStatus.ensure_defaults!
    end

    assert UserTokenDbscStatus.exists?(id: UserTokenDbscStatus::REVOKE)
  end

  test "ensure_defaults! skips existing records" do
    UserTokenDbscStatus.count

    assert_no_difference("UserTokenDbscStatus.count") do
      UserTokenDbscStatus.ensure_defaults!
    end
  end

  test "ensure_defaults! does nothing when all exist" do
    assert_no_difference("UserTokenDbscStatus.count") do
      UserTokenDbscStatus.ensure_defaults!
    end
  end

  test "ensure_defaults! handles empty DEFAULTS" do
    original_defaults = UserTokenDbscStatus::DEFAULTS
    UserTokenDbscStatus.send(:remove_const, :DEFAULTS)
    UserTokenDbscStatus.const_set(:DEFAULTS, [].freeze)

    assert_no_difference("UserTokenDbscStatus.count") do
      UserTokenDbscStatus.ensure_defaults!
    end
  ensure
    UserTokenDbscStatus.send(:remove_const, :DEFAULTS)
    UserTokenDbscStatus.const_set(:DEFAULTS, original_defaults)
  end

  test "user_tokens association works with dependent restrict" do
    status = UserTokenDbscStatus.find(UserTokenDbscStatus::NOTHING)
    user = User.create!(
      status_id: UserStatus::NOTHING,
      multi_factor_enabled: false,
    )

    user_token = UserToken.create!(
      user: user,
      user_token_status_id: UserTokenStatus::NOTHING,
      user_token_kind_id: UserTokenKind::BROWSER_WEB,
      user_token_dbsc_status_id: status.id,
      refresh_expires_at: 1.day.from_now,
      deletable_at: 1.day.from_now,
    )

    assert_includes status.user_tokens, user_token

    assert_not status.destroy
    assert_predicate status.errors[:base], :present?
  end
end
