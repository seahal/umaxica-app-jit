require "test_helper"

module News
  module Com
    module V1
      class HealthsControllerTest < ActionDispatch::IntegrationTest
        setup do
          host! ENV.fetch("NEWS_CORPORATE_URL", "news.com.localhost")
        end

        test "returns success for default format" do
          get public_send(:news_com_v1_health_path, default_url_query)
          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns success for explicit html format" do
          get public_send(:news_com_v1_health_path, default_url_query.merge(format: :html))
          assert_response :success
          assert_includes response.body, "OK"
        end

        test "returns OK status payload for json format" do
          get public_send(:news_com_v1_health_path, default_url_query.merge(format: :json))
          assert_response :success
          assert_equal "OK", response.parsed_body["status"]
        end

        test "raises error for unsupported yaml format" do
          assert_raises(RuntimeError) do
            get public_send(:news_com_v1_health_path, default_url_query.merge(format: :yaml))
          end
        end
      end
    end
  end
end
