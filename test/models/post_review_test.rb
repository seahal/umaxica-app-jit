require "test_helper"

class PostReviewTest < ActiveSupport::TestCase
  test "validations" do
    review = PostReview.new
    assert_not review.valid?
  end
end
