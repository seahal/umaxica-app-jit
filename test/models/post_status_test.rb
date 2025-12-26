require "test_helper"

class PostStatusTest < ActiveSupport::TestCase
  test "validations" do
    status = PostStatus.new
    assert_not status.valid?
  end
end
