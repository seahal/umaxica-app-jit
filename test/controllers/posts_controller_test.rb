# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  fixtures :avatars, :handles, :avatar_capabilities, :post_statuses

  test "search escapes % character" do
    avatar = avatars(:one)
    # 1) Prepare a Post with body "100% real" and another with "100X real"
    post_percent = Post.create!(
      body: "100% real",
      author_avatar: avatar,
      created_by_actor_id: avatar.id,
      public_id: SecureRandom.hex(10),
      post_status_id: PostStatus::NEYO,
    )
    post_other = Post.create!(
      body: "100X real",
      author_avatar: avatar,
      created_by_actor_id: avatar.id,
      public_id: SecureRandom.hex(10),
      post_status_id: PostStatus::NEYO,
    )

    # Query for "100%" should only hit "100% real"
    get posts_url, params: { q: "100%" }

    assert_response :success
    json = response.parsed_body
    ids = json.pluck("id")
    assert_includes ids, post_percent.id
    assert_not_includes ids, post_other.id
  end

  test "search escapes _ character" do
    avatar = avatars(:one)
    # 2) Prepare Posts with "a_b" and "acb"
    post_underscore = Post.create!(
      body: "a_b",
      author_avatar: avatar,
      created_by_actor_id: avatar.id,
      public_id: SecureRandom.hex(10),
      post_status_id: PostStatus::NEYO,
    )
    post_other = Post.create!(
      body: "acb",
      author_avatar: avatar,
      created_by_actor_id: avatar.id,
      public_id: SecureRandom.hex(10),
      post_status_id: PostStatus::NEYO,
    )

    # Query for "a_b" should only hit "a_b"
    get posts_url, params: { q: "a_b" }

    assert_response :success
    json = response.parsed_body
    ids = json.pluck("id")
    assert_includes ids, post_underscore.id
    assert_not_includes ids, post_other.id
  end
end
