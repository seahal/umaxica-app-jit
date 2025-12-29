# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
#
#  id         :string           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_avatar_ownership_statuses_on_key  (key) UNIQUE
#

require "test_helper"

class AvatarOwnershipStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarOwnershipStatus.new
    assert_not status.valid?
  end
end
