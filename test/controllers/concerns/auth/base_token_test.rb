# frozen_string_literal: true

require "test_helper"

module Auth
  class BaseTokenTest < ActiveSupport::TestCase
    test "Token.encode returns nil for nil resource" do
      result = Auth::Base::Token.encode(nil, host: "example.com")
      assert_nil result
    end

    test "Token.encode returns nil for blank host" do
      user = users(:one)
      result = Auth::Base::Token.encode(user, host: "")
      assert_nil result
    end

    test "Token.decode returns nil for blank token" do
      result = Auth::Base::Token.decode("", host: "example.com")
      assert_nil result
    end

    test "Token.decode returns nil for blank host" do
      result = Auth::Base::Token.decode("some_token", host: "")
      assert_nil result
    end

    test "Token.extract_subject returns subject from payload" do
      payload = { "sub" => 123 }
      assert_equal 123, Auth::Base::Token.extract_subject(payload)
    end

    test "Token.extract_type returns type from payload" do
      payload = { "type" => "user" }
      assert_equal "user", Auth::Base::Token.extract_type(payload)
    end

    test "Token.extract_session_id returns sid from payload" do
      payload = { "sid" => "abc123" }
      assert_equal "abc123", Auth::Base::Token.extract_session_id(payload)
    end

    test "Token.extract_jti returns jti from payload" do
      payload = { "jti" => "xyz789" }
      assert_equal "xyz789", Auth::Base::Token.extract_jti(payload)
    end
  end
end
