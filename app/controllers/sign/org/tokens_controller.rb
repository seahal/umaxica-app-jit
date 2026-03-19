# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class TokensController < ApplicationController
      public_strict!
      skip_before_action :verify_authenticity_token

      def create
        render json: { error: "not_implemented", error_description: "Staff SSO is not yet available" },
               status: :not_implemented
      end
    end
  end
end
