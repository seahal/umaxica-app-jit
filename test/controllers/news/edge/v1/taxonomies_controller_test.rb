# frozen_string_literal: true

require "set"
require "test_helper"

module News
  module Edge
    module V1
      class TaxonomiesControllerTest < ActionDispatch::IntegrationTest
        include TaxonomyTestHelper

        TAXONOMY_SPECS = [
          {
            name: "news com tags",
            url_helper: :news_com_edge_v1_tags_url,
            model: ComTimelineTagMaster,
            host_env: "NEWS_CORPORATE_URL",
            default_host: "news.com.localhost",
          },
          {
            name: "news com categories",
            url_helper: :news_com_edge_v1_categories_url,
            model: ComTimelineCategoryMaster,
            host_env: "NEWS_CORPORATE_URL",
            default_host: "news.com.localhost",
          },
          {
            name: "news app tags",
            url_helper: :news_app_edge_v1_tags_url,
            model: AppTimelineTagMaster,
            host_env: "NEWS_SERVICE_URL",
            default_host: "news.app.localhost",
          },
          {
            name: "news app categories",
            url_helper: :news_app_edge_v1_categories_url,
            model: AppTimelineCategoryMaster,
            host_env: "NEWS_SERVICE_URL",
            default_host: "news.app.localhost",
          },
          {
            name: "news org tags",
            url_helper: :news_org_edge_v1_tags_url,
            model: OrgTimelineTagMaster,
            host_env: "NEWS_STAFF_URL",
            default_host: "news.org.localhost",
          },
          {
            name: "news org categories",
            url_helper: :news_org_edge_v1_categories_url,
            model: OrgTimelineCategoryMaster,
            host_env: "NEWS_STAFF_URL",
            default_host: "news.org.localhost",
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
