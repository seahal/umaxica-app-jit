# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  # Assuming Post model exists as per task description

  test "search escapes % character" do
    # 1) Prepare a Post with title "100% real" and another with "100X real"
    post_percent = Post.create!(title: "100% real")
    post_other = Post.create!(title: "100X real")

    # Query for "100%" should only hit "100% real"
    get posts_url, params: { q: "100%" }

    assert_response :success
    assert_includes assigns(:posts), post_percent
    assert_not_includes assigns(:posts), post_other
  end

  test "search escapes _ character" do
    # 2) Prepare Posts with "a_b" and "acb"
    post_underscore = Post.create!(title: "a_b")
    post_other = Post.create!(title: "acb")

    # Query for "a_b" should only hit "a_b"
    get posts_url, params: { q: "a_b" }

    assert_response :success
    assert_includes assigns(:posts), post_underscore
    assert_not_includes assigns(:posts), post_other
  end
end
