# typed: false
# frozen_string_literal: true

    require "test_helper"

    class Post::App::Auth::CallbacksControllerTest < ActionDispatch::IntegrationTest
      setup do
        @host = ENV.fetch("DISTRIBUTOR_POST_APP_URL", "docs.app.localhost")
      end

      test "returns client_id as post_app" do
        controller = Post::App::Auth::CallbacksController.new

        assert_equal "post_app", controller.send(:oidc_client_id)
      end

      test "callback route exists" do
        assert_routing(
          { method: :get, path: "http://#{@host}/auth/callback" },
          { host: @host, controller: "jit/distributor/post/app/auth/callbacks", action: "show" },
        )
      end
    end
  end
end
