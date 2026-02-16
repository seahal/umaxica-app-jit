# frozen_string_literal: true

require "test_helper"

module Core
  class SurfaceMiddlewareTest < ActiveSupport::TestCase
    test "sets jit.surface env before app call" do
      downstream =
        lambda do |env|
          [200, { "Content-Type" => "text/plain" }, [env[Core::Surface::ENV_KEY].to_s]]
        end

      middleware = Core::SurfaceMiddleware.new(downstream)
      env = Rack::MockRequest.env_for("http://org.localhost/")

      _status, _headers, body = middleware.call(env)

      assert_equal "org", body.each.to_a.join
    end
  end
end
