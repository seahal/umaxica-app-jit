# typed: false
# frozen_string_literal: true

require "set"
require "test_helper"

module Docs
  module Edge
    module V1
      class TaxonomiesControllerTest < ActionDispatch::IntegrationTest
        include TaxonomyTestHelper

        TAXONOMY_SPECS = [
          {
            name: "docs com tags",
            url_helper: :docs_com_edge_v1_tags_url,
            model: ComDocumentTagMaster,
            host_env: "DOCS_CORPORATE_URL",
            default_host: "docs.com.localhost",
          },
          {
            name: "docs com categories",
            url_helper: :docs_com_edge_v1_categories_url,
            model: ComDocumentCategoryMaster,
            host_env: "DOCS_CORPORATE_URL",
            default_host: "docs.com.localhost",
          },
          {
            name: "docs app tags",
            url_helper: :docs_app_edge_v1_tags_url,
            model: AppDocumentTagMaster,
            host_env: "DOCS_SERVICE_URL",
            default_host: "docs.app.localhost",
          },
          {
            name: "docs app categories",
            url_helper: :docs_app_edge_v1_categories_url,
            model: AppDocumentCategoryMaster,
            host_env: "DOCS_SERVICE_URL",
            default_host: "docs.app.localhost",
          },
          {
            name: "docs org tags",
            url_helper: :docs_org_edge_v1_tags_url,
            model: OrgDocumentTagMaster,
            host_env: "DOCS_STAFF_URL",
            default_host: "docs.org.localhost",
          },
          {
            name: "docs org categories",
            url_helper: :docs_org_edge_v1_categories_url,
            model: OrgDocumentCategoryMaster,
            host_env: "DOCS_STAFF_URL",
            default_host: "docs.org.localhost",
          },
        ].freeze

        TAXONOMY_SPECS.each do |spec|
          test "returns #{spec[:name]} taxonomy" do
            host! ENV.fetch(spec[:host_env], spec[:default_host])
            tree = build_taxonomy_tree_for(spec[:model])

            get send(spec[:url_helper])

            assert_response :success
            data = response.parsed_body["data"]
            assert_instance_of Array, data

            root_node = find_node(data, tree[:root].id)
            assert_not_nil root_node
            assert_equal tree[:root].name, root_node["name"]

            child_ids = root_node["children"].pluck("id").to_set
            expected_child_ids = Set[tree[:a].id, tree[:b].id, tree[:c].id]
            assert_equal expected_child_ids, child_ids

            c_node = find_node(data, tree[:c].id)
            assert_not_nil c_node
            assert_equal [tree[:c1].id], c_node["children"].pluck("id")
          end
        end

        private

        def find_node(nodes, id)
          nodes.each do |node|
            return node if node["id"] == id

            found = find_node(node["children"], id)
            return found if found
          end

          nil
        end
      end
    end
  end
end
