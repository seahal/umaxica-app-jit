# frozen_string_literal: true

require "test_helper"

class AdminStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "validates length of id" do
    record = AdminStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
