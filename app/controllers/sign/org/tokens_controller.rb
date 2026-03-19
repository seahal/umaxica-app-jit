# typed: false
# frozen_string_literal: true

module Sign
  module Org
    class TokensController < ApplicationController
      public_strict!
      protect_from_forgery with: :null_session

      def create
        render json: { error: "not_implemented", error_description: "Staff SSO is not yet available" },
               status: :not_implemented
      end
    end
  end
end
