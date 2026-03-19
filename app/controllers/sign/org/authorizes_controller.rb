# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class AuthorizesController < ApplicationController
      auth_required!
      before_action :authenticate!

      def show
        # Staff OIDC authorization - extensible stub
        # Currently returns 501 until staff SSO is implemented
        render json: { error: "not_implemented", error_description: "Staff SSO is not yet available" },
               status: :not_implemented
      end
    end
  end
end
