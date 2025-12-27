# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_roles
#
#  id          :string           not null, primary key
#  key         :string           not null
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_avatar_roles_on_key  (key) UNIQUE
#

require "test_helper"

class AvatarRoleTest < ActiveSupport::TestCase
  test "validations" do
    role = AvatarRole.new
    assert_not role.valid?
    assert_not role.errors[:key].empty?
    assert_not role.errors[:name].empty?
  end
end
