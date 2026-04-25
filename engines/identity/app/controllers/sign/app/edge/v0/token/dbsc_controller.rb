# typed: false
# frozen_string_literal: true

module Jit::Identity
    class Sign::App::Edge::V0::Token::DbscController < Jit::Identity::Sign::App::ApplicationController
      include Jit::Identity::Sign::EdgeV0JsonApi

      activate_edge_v0_json_api
      include Jit::Identity::Sign::DbscRegistrationEndpoint

      public_strict!
      skip_before_action :set_preferences_cookie
      skip_before_action :transparent_refresh_access_token

      private

      def dbsc_url
        identity.sign_app_edge_v0_token_dbsc_url
      end
    end
  end
end
