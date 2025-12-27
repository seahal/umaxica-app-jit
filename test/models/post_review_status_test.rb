# frozen_string_literal: true

# == Schema Information
#
# Table name: post_review_statuses
#
#  id          :string           not null, primary key
#  key         :string           not null
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_post_review_statuses_on_key  (key) UNIQUE
#

require "test_helper"

class PostReviewStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = PostReviewStatus.new
    assert_not status.valid?
  end
end
