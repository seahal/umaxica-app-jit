# frozen_string_literal: true

module Sign
  module Org
    module Oauth
      class ApplesController < ApplicationController
        protect_from_forgery with: :exception

        # TODO: Implement staff Apple OAuth support.
        def create
          redirect_to "/auth/apple", allow_other_host: false, status: :see_other
        end

        def callback
          head :not_implemented
        end

        def failure
          head :not_implemented
        end
      end
    end
  end
end
