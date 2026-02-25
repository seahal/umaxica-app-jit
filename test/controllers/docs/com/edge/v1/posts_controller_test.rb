# typed: false
# frozen_string_literal: true

require "test_helper"

module Docs
  module Com
    module Edge
      module V1
        class PostsControllerTest < ActionDispatch::IntegrationTest
          fixtures :com_documents, :com_document_statuses

          setup do
            @document = com_documents(:one)
            host! ENV.fetch("DOCS_CORPORATE_URL", "docs.com.localhost")
          end

          test "should show 404 for non-existent permalink" do
            get docs_com_edge_v1_post_url(id: "nonexistent_permalink_xyz")

            assert_response :not_found
          end

          test "should not show expired documents" do
            expired_doc = ComDocument.create!(
              permalink: "expired_test_#{SecureRandom.hex(4)}",
              response_mode: "html",
              published_at: 2.days.ago,
              expires_at: 1.day.ago,
              status_id: ComDocumentStatus::ACTIVE,
              revision_key: SecureRandom.hex(16),
            )

            get docs_com_edge_v1_post_url(id: expired_doc.permalink)

            assert_response :not_found
          end

          test "should not show unpublished documents" do
            future_doc = ComDocument.create!(
              permalink: "future_test_#{SecureRandom.hex(4)}",
              response_mode: "html",
              published_at: 1.day.from_now,
              expires_at: 100.years.from_now,
              status_id: ComDocumentStatus::ACTIVE,
              revision_key: SecureRandom.hex(16),
            )

            get docs_com_edge_v1_post_url(id: future_doc.permalink)

            assert_response :not_found
          end

          # List/Search tests (from FindController)
          test "should show all documents list" do
            get docs_com_edge_v1_posts_url

            assert_response :success
          end

          test "should search documents by query" do
            get docs_com_edge_v1_posts_url(q: "test")

            assert_response :success
          end
        end
      end
    end
  end
end
