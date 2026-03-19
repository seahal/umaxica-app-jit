# typed: false
# frozen_string_literal: true

module Help
  module App
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "help_app"
        end
      end
    end
  end
end
