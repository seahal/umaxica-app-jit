# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_notifications
#
#  id         :uuid             not null, primary key
#  staff_id   :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  public_id  :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_staff_notifications_on_staff_id  (staff_id)
#

require "test_helper"

class StaffNotificationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
