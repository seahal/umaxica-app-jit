# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_moniker_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class AvatarMonikerStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = AvatarMonikerStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
  end
end
