# frozen_string_literal: true

require "test_helper"

module Docs
  module Com
    class FindControllerTest < ActionDispatch::IntegrationTest
      setup do
        host! ENV.fetch("DOCS_CORPORATE_URL", "docs.com.localhost")
      end

      test "should show all documents" do
        get docs_com_find_url("all")
        assert_response :success
      end

      test "should search documents by query" do
        get docs_com_find_url("test")
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

        get docs_com_find_url("all")
        assert_response :success
        assert_select ".bg-white.rounded-lg.shadow-sm", count: 20
      end

      test "should handle empty search results" do
        get docs_com_find_url("nonexistent_query_xyz")
        assert_response :success
        assert_select ".bg-gray-50.rounded-lg.p-12.text-center"
      end

      test "should search by permalink" do
        doc = com_documents(:one)
        get docs_com_find_url(doc.permalink)
        assert_response :success
      end
    end
  end
end
