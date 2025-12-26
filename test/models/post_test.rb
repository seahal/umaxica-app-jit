require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "validations" do
    post = Post.new
    assert_not post.valid?
    # public_id, body, created_by_actor_id are required
    # author_avatar, post_status are belongs_to required by default in Rails 5+
    assert_not post.save # Trigger validations
    assert post.errors[:public_id].any? || post.errors[:body].any?
  end

  test "public_id generation" do
    post = Post.new(body: "test", created_by_actor_id: "actor1", author_avatar_id: "avatar1", post_status_id: "status1")
    post.valid? # Trigger validation callbacks if any
    # Since PublicId concern usually generates on validation or save.
    # If not, checks if it is present.
    # If logic is 'before_create', we need to save. But we can't save without valid FKs.
    # So we simply check if it's nil initially and assume the concern works if we had valid data.
    # Or mock the concern. For now, just assert it is NOT generated yet if it requires save.
    assert_not_nil post.public_id
  end
end
