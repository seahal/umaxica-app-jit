# == Schema Information
#
# Table name: user_notifications
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  public_id  :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  updated_at :datetime         not null
#  user_id    :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#

require "test_helper"

class UserNotificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
