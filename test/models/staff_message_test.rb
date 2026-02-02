# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_messages
# Database name: message
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :uuid             not null
#  staff_id   :bigint           not null
#
# Indexes
#
#  index_staff_messages_on_public_id  (public_id) UNIQUE
#  index_staff_messages_on_staff_id   (staff_id)
#

require "test_helper"

class StaffMessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
