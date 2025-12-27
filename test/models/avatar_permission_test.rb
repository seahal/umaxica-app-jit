# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_permissions
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
#  index_avatar_permissions_on_key  (key) UNIQUE
#

require "test_helper"

class AvatarPermissionTest < ActiveSupport::TestCase
  test "validations" do
    perm = AvatarPermission.new
    assert_not perm.valid?
  end
end
