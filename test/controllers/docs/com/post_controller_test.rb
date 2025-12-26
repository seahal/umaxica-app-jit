# frozen_string_literal: true

require "test_helper"

module Docs
  module Com
    class PostControllerTest < ActionDispatch::IntegrationTest
      setup do
        @document = com_documents(:one)
        host! ENV.fetch("DOCS_CORPORATE_URL", "docs.com.localhost")
      end

      test "should show document by permalink" do
        get docs_com_post_url(id: @document.permalink)
        assert_response :success
      end

      test "should display document title and content" do
        get docs_com_post_url(id: @document.permalink)
        assert_response :success

        # Check that the document is displayed (can't verify exact text due to encryption)
        assert_select "h1"
        assert_select "article"
      end

      test "should show 404 for non-existent permalink" do
        get docs_com_post_url(id: "nonexistent_permalink_xyz")
        assert_response :not_found
      end

      test "should handle redirect response mode" do
        redirect_doc = ComDocument.create!(
          permalink: "redirect_test_#{SecureRandom.hex(4)}",
          response_mode: "redirect",
          redirect_url: "https://example.com",
          published_at: Time.current,
          expires_at: 100.years.from_now,
          status_id: "ACTIVE",
        )

        get docs_com_post_url(id: redirect_doc.permalink)
        assert_redirected_to "https://example.com"
      end

      test "should handle text response mode" do
        text_doc = ComDocument.create!(
          permalink: "text_test_#{SecureRandom.hex(4)}",
          response_mode: "text",
          published_at: Time.current,
          expires_at: 100.years.from_now,
          status_id: "ACTIVE",
        )

        text_doc.com_document_versions.create!(
          permalink: text_doc.permalink,
          response_mode: text_doc.response_mode,
          title: "Text Document",
          body: "Plain text content",
          published_at: text_doc.published_at,
          expires_at: text_doc.expires_at,
          edited_by_type: "Staff",
        )

        get docs_com_post_url(id: text_doc.permalink)
        assert_response :success
        assert_equal "text/plain; charset=utf-8", response.content_type
        assert_equal "Plain text content", response.body
      end

      test "should not show expired documents" do
        expired_doc = ComDocument.create!(
          permalink: "expired_test_#{SecureRandom.hex(4)}",
          response_mode: "html",
          published_at: 2.days.ago,
          expires_at: 1.day.ago,
          status_id: "ACTIVE",
        )

        get docs_com_post_url(id: expired_doc.permalink)
        assert_response :not_found
      end

      test "should not show unpublished documents" do
        future_doc = ComDocument.create!(
          permalink: "future_test_#{SecureRandom.hex(4)}",
          response_mode: "html",
          published_at: 1.day.from_now,
          expires_at: 100.years.from_now,
          status_id: "ACTIVE",
        )

        get docs_com_post_url(id: future_doc.permalink)
        assert_response :not_found
      end

      test "should display version history" do
        get docs_com_post_url(id: @document.permalink)
        assert_response :success
        assert_select ".space-y-2" # Version history container
      end
    end
  end
end
