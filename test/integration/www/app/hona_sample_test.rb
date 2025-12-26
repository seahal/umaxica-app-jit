# frozen_string_literal: true

# require "test_helper"
# require "rack/utils"

# module Top
#   module App
#     class HonaSampleTest < ActionDispatch::IntegrationTest
#       CASES = [
#         [ { lx: "ja", ri: "jp" }, { lx: nil,   ri: "jp" } ],
#         [ { lx: "en", ri: "jp" }, { lx: "en", ri: "jp" } ],
#         [ { lx: "kr", ri: "jp" }, { lx: nil,   ri: "jp" } ],
#         [ { lx: nil,   ri: "jp" }, { lx: nil,   ri: "jp" } ],
#         [ { lx: "",   ri: "jp" }, { lx: nil,   ri: "jp" } ]
#       ].freeze

# ===== Dynamically define each test =====
#       CASES.each_with_index do |(input, expected), idx|
#         test "case #{idx}: query normalize #{input.inspect} -> #{expected.inspect}" do
#           get_with_query(top_app_preference_url, input)

#           assert_query_params_equal expected, "[case #{idx}]"
#           assert_no_unexpected_params %i[lx ri], "[case #{idx}]"
#         end
#       end

#       # ===== Helpers =====
#       private

#       def get_with_query(url_or_path, params)
#         query = params.map { |k, v| "#{k}=#{v}" }.join("&")
#         get "#{url_or_path}?#{query}"
#         follow_redirects
#       end

#       def follow_redirects(max_hops: 5)
#         hops = 0
#         while response.redirect? && hops < max_hops
#           follow_redirect!
#           hops += 1
#         end
#       end

#       def current_query_hash
#         Rack::Utils
#           .parse_nested_query(@request.query_string.to_s)
#           .transform_keys(&:to_sym)
#       end

#       def assert_query_params_equal(expected, prefix)
#         actual = current_query_hash
#         expected.each do |key, value|
#           if value.nil?
#             assert_nil actual[key], "#{prefix} #{key} should be nil but was #{actual[key].inspect}"
#           else
#             assert_equal value, actual[key], "#{prefix} #{key} mismatch (got #{actual[key].inspect})"
#           end
#         end
#       end

#       def assert_no_unexpected_params(allowed_keys, prefix)
#         unexpected = current_query_hash.keys - allowed_keys

#         assert_empty unexpected, "#{prefix} unexpected keys: #{unexpected.inspect}"
#       end
#     end
#   end
# end
