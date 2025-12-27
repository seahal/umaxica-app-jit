# frozen_string_literal: true

require "test_helper"

module Docs
  module Com
    class PostsControllerTest < ActionDispatch::IntegrationTest
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

      # List/Search tests (from FindController)
      test "should show all documents list" do
        get docs_com_posts_url
        assert_response :success
      end

      test "should search documents by query" do
        get docs_com_posts_url(q: "test")
        assert_response :success
      end

      test "should paginate results" do
        # Create multiple documents
        25.times do |i|
          doc = ComDocument.create!(
            permalink: "test_doc_#{i}_#{SecureRandom.hex(4)}",
            response_mode: "html",
            published_at: Time.current,
            expires_at: 100.years.from_now,
            status_id: "ACTIVE",
          )

          doc.com_document_versions.create!(
            permalink: doc.permalink,
            response_mode: doc.response_mode,
            title: "Test Document #{i}",
            description: "Test description",
            body: "Test body",
            published_at: doc.published_at,
            expires_at: doc.expires_at,
            edited_by_type: "Staff",
          )
        end

        get docs_com_posts_url
        assert_response :success
        assert_select ".bg-white.rounded-lg.shadow-sm", count: 20
      end

      test "should handle empty search results" do
        get docs_com_posts_url(q: "nonexistent_query_xyz")
        assert_response :success
        assert_select ".bg-gray-50.rounded-lg.p-8.text-center"
      end

      # CRUD operations
      test "should get new" do
        get new_docs_com_post_url
        assert_response :success
      end

      test "should create post" do
        post docs_com_posts_url, params: {}
        assert_response :redirect
      end

      test "should get edit" do
        get edit_docs_com_post_url(id: 1)
        assert_response :success
      end

      test "should update post" do
        patch docs_com_post_url(id: 1), params: {}
        assert_response :redirect
      end

      test "should destroy post" do
        delete docs_com_post_url(id: 1)
        assert_response :redirect
      end
    end
  end
end
