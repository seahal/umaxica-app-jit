# == Schema Information
#
# Table name: staff_messages
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  public_id  :uuid
#  staff_id   :uuid
#  updated_at :datetime         not null
#

require "test_helper"

class StaffMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
