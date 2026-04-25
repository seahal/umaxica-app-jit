# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    module Acme
      module App
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "acme_app"
            end
          end
        end
      end
    end
  end
end
