# typed: false
# frozen_string_literal: true

module Core
  module App
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "core_app"
        end
      end
    end
  end
end
