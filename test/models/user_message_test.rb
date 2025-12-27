# frozen_string_literal: true

# == Schema Information
#
# Table name: user_messages
#
#  id         :uuid             not null, primary key
#  user_id    :uuid
#  public_id  :uuid
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
