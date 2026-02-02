# frozen_string_literal: true

# == Schema Information
#
# Table name: post_review_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_post_review_statuses_on_code  (code) UNIQUE
#

require "test_helper"

class PostReviewStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = PostReviewStatus.new
    assert_not status.valid?
  end

  test "validates length of id" do
    record = PostReviewStatus.new(id: "A" * 256)
    assert_predicate record, :invalid?
    assert_predicate record.errors[:id], :any?
  end
end
