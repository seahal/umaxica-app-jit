# frozen_string_literal: true

# == Schema Information
#
# Table name: user_apple_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_apple_auths_on_user_id  (user_id)
#
require "test_helper"

class UserAppleAuthTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
