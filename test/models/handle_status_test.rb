# frozen_string_literal: true

# == Schema Information
#
# Table name: handle_statuses
#
#  id         :string           not null, primary key
#  key        :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_handle_statuses_on_key  (key) UNIQUE
#

require "test_helper"

class HandleStatusTest < ActiveSupport::TestCase
  test "valid status" do
    status = HandleStatus.new(key: "TEST_STATUS", name: "Test Status")
    assert_predicate status, :valid?
    assert status.save
  end

  test "requires key" do
    status = HandleStatus.new(name: "No Key")
    assert_not status.valid?
    assert_not_empty status.errors[:key]
  end

  test "requires name" do
    status = HandleStatus.new(key: "NONAME")
    assert_not status.valid?
    assert_not_empty status.errors[:name]
  end
end
