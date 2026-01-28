# frozen_string_literal: true

# == Schema Information
#
# Table name: user_messages
# Database name: message
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :uuid
#  user_id    :uuid             not null
#
# Indexes
#
#  index_user_messages_on_user_id  (user_id)
#

require "test_helper"

class UserMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
