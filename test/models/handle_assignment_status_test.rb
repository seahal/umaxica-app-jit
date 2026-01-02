# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_assignment_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "test_helper"

class HandleAssignmentStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = HandleAssignmentStatus.new(id: "VALID_STATUS")
    assert_predicate status, :valid?
  end
end
