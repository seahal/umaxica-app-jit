# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_roles
# Database name: avatar
#
#  id :bigint           not null, primary key
#

require "test_helper"

class AvatarRoleTest < ActiveSupport::TestCase
  test "constants have expected values" do
    assert_equal 1, AvatarRole::NOTHING
    assert_equal 2, AvatarRole::VIEWER
    assert_equal 3, AvatarRole::EDITOR
    assert_equal 4, AvatarRole::ADMIN
  end

  test "has_many avatar_role_permissions association is defined" do
    association = AvatarRole.reflect_on_association(:avatar_role_permissions)

    assert_not_nil association
    assert_equal :has_many, association.macro
  end

  test "has_many avatar_permissions through association is defined" do
    association = AvatarRole.reflect_on_association(:avatar_permissions)

    assert_not_nil association
    assert_equal :has_many, association.macro
    assert_equal :avatar_role_permissions, association.options[:through]
  end

  test "has_many avatar_memberships association is defined" do
    association = AvatarRole.reflect_on_association(:avatar_memberships)

    assert_not_nil association
    assert_equal :has_many, association.macro
    assert_equal "role_id", association.foreign_key.to_s
  end

  test "does not record timestamps" do
    assert_not AvatarRole.record_timestamps
  end
end
