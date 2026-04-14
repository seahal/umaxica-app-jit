# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_permissions
# Database name: avatar
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AvatarPermissionTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, AvatarPermission::NOTHING
    assert_equal 2, AvatarPermission::READ
    assert_equal 3, AvatarPermission::WRITE
    assert_equal 4, AvatarPermission::ADMIN
  end

  test "has_many avatar_role_permissions association is defined" do
    association = AvatarPermission.reflect_on_association(:avatar_role_permissions)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many avatar_role_permissions has dependent restrict_with_error" do
    association = AvatarPermission.reflect_on_association(:avatar_role_permissions)

    assert_equal :restrict_with_error, association.options[:dependent]
  end

  test "has_many avatar_roles through association is defined" do
    association = AvatarPermission.reflect_on_association(:avatar_roles)

    assert_not_nil association
    assert_equal :has_many, association.macro
    assert_equal :avatar_role_permissions, association.options[:through]
  end

  test "does not record timestamps" do
    assert_not AvatarPermission.record_timestamps
  end
end
