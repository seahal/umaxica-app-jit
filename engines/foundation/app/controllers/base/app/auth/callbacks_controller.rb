# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module App
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "base_app"
            end
          end
        end
      end
    end
  end
end
