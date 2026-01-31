# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#

require "test_helper"

class PostStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = PostStatus.new(id: "TEST_STATUS")
    assert_predicate status, :valid?
  end

  test "validates length of id" do
    record = PostStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
