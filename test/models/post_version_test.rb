# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: post_versions
# Database name: avatar
#
#  id             :bigint           not null, primary key
#  body           :text
#  description    :string
#  edited_by_type :string
#  expires_at     :datetime         not null
#  permalink      :string(200)      not null
#  published_at   :datetime         not null
#  redirect_url   :string
#  response_mode  :string           not null
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  edited_by_id   :bigint
#  post_id        :bigint           not null
#  public_id      :string           default(""), not null
#
# Indexes
#
#  index_post_versions_on_edited_by_id            (edited_by_id)
#  index_post_versions_on_post_id_and_created_at  (post_id,created_at DESC)
#  index_post_versions_on_public_id               (public_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id) ON DELETE => cascade
#

require "test_helper"

class PostVersionTest < ActiveSupport::TestCase
  def setup
    @post = posts(:one)
  end

  test "should be valid with required attributes" do
    version = PostVersion.new(
      post: @post,
      permalink: "test-post-#{SecureRandom.hex(4)}",
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_predicate version, :valid?
  end

  test "should require post" do
    version = PostVersion.new(
      permalink: "test-post",
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not version.valid?
    assert_not_empty version.errors[:post]
  end

  test "should require permalink" do
    version = PostVersion.new(
      post: @post,
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not version.valid?
    assert_not_empty version.errors[:permalink]
  end

  test "should require response_mode" do
    version = PostVersion.new(
      post: @post,
      permalink: "test-post",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not version.valid?
    assert_not_empty version.errors[:response_mode]
  end

  test "should require published_at" do
    version = PostVersion.new(
      post: @post,
      permalink: "test-post",
      response_mode: "markdown",
      expires_at: 1.year.from_now,
    )

    assert_not version.valid?
    assert_not_empty version.errors[:published_at]
  end

  test "should require expires_at" do
    version = PostVersion.new(
      post: @post,
      permalink: "test-post",
      response_mode: "markdown",
      published_at: Time.current,
    )

    assert_not version.valid?
    assert_not_empty version.errors[:expires_at]
  end

  test "permalink exactly 200 characters is valid at upper boundary" do
    version = PostVersion.new(
      post: @post,
      permalink: "a" * 200,
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_predicate version, :valid?
  end

  test "permalink 201 characters is invalid above upper boundary" do
    version = PostVersion.new(
      post: @post,
      permalink: "a" * 201,
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_not version.valid?
    assert_not_empty version.errors[:permalink]
  end

  test "belongs to post" do
    version = PostVersion.create!(
      post: @post,
      permalink: "test-post-#{SecureRandom.hex(4)}",
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_equal @post, version.post
  end

  test "public_id is automatically generated" do
    version = PostVersion.create!(
      post: @post,
      permalink: "test-post-#{SecureRandom.hex(4)}",
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    assert_predicate version.public_id, :present?
    assert_equal 21, version.public_id.length
  end

  test "public_id must be unique" do
    version1 = PostVersion.create!(
      post: @post,
      permalink: "test-post-1-#{SecureRandom.hex(4)}",
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )

    version2 = PostVersion.new(
      post: @post,
      permalink: "test-post-2-#{SecureRandom.hex(4)}",
      response_mode: "markdown",
      published_at: Time.current,
      expires_at: 1.year.from_now,
    )
    version2.public_id = version1.public_id

    assert_not version2.valid?
    assert_not_empty version2.errors[:public_id]
  end
end
