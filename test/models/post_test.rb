# frozen_string_literal: true

# == Schema Information
#
# Table name: posts
#
#  id                    :string           not null, primary key
#  public_id             :string           default(""), not null
#  author_avatar_id      :string           not null
#  post_status_id        :string           not null
#  body                  :text             not null
#  created_by_actor_id   :string           not null
#  published_by_actor_id :string
#  published_at          :timestamptz
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_posts_on_author_avatar_id_and_created_at  (author_avatar_id,created_at)
#  index_posts_on_post_status_id                   (post_status_id)
#  index_posts_on_public_id                        (public_id) UNIQUE
#

require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @capability = AvatarCapability.find_or_create_by!(key: "post_test_cap", name: "Post Test")
    @handle = Handle.find_or_create_by!(handle: "post_test_handle") { |h| h.cooldown_until = Time.current }
    @avatar =
      Avatar.find_or_create_by!(moniker: "Post Author") do |a|
        a.capability = @capability
        a.active_handle = @handle
      end
    @status =
      PostStatus.find_or_create_by!(id: "DRAFT") do |s|
        s.key = "draft"
        s.name = "Draft"
      end
    @valid_attributes = {
      author_avatar: @avatar,
      post_status: @status,
      body: "Valid post body content",
      created_by_actor_id: "user-1",
    }.freeze
  end

  test "valid post creation" do
    post = Post.new(@valid_attributes)
    assert_predicate post, :valid?
    assert post.save
    assert_not_nil post.public_id
  end

  test "body is invalid when nil" do
    post = Post.new(@valid_attributes.merge(body: nil))
    assert_not post.valid?
    assert_not_empty post.errors[:body]
  end

  test "body is invalid when empty" do
    post = Post.new(@valid_attributes.merge(body: ""))
    assert_not post.valid?
    assert_not_empty post.errors[:body]
  end

  test "body is invalid when only whitespace" do
    post = Post.new(@valid_attributes.merge(body: "   "))
    assert_not post.valid?
    assert_not_empty post.errors[:body]
  end

  test "public_id uniqueness" do
    Post.create!(@valid_attributes)
    duplicate = Post.new(@valid_attributes.merge(public_id: Post.last.public_id))
    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:public_id]
  end

  test "public_id length maximum boundary" do
    post = Post.new(@valid_attributes.merge(public_id: "a" * 22))
    assert_not post.valid?
    assert_not_empty post.errors[:public_id]
  end

  test "association: belongs_to author_avatar" do
    post = Post.create!(@valid_attributes)
    assert_equal @avatar, post.author_avatar
  end

  test "association: belongs_to post_status" do
    post = Post.create!(@valid_attributes)
    assert_equal @status, post.post_status
  end

  test "association deletion: restriction by post_reviews" do
    post = Post.create!(@valid_attributes)
    # PostReview might require more fields, assuming basic creation works for now
    # Create status if not exists
    PostReviewStatus.find_or_create_by!(id: "PENDING") { |s| s.key = "pending"; s.name = "Pending" }
    PostReview.create!(
      post: post, reviewer_actor_id: @avatar.id, post_review_status_id: "PENDING",
      decided_at: Time.current,
    )

    assert_not post.destroy
    assert_includes post.errors[:base], "Cannot delete record because dependent post_reviews exist"
  end
end
