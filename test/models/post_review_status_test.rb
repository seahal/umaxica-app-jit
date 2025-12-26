require "test_helper"

class PostReviewStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = PostReviewStatus.new
    assert_not status.valid?
  end
end
