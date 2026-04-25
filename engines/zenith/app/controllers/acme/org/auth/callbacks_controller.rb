# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    module Acme
      module Org
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "acme_org"
            end
          end
        end
      end
    end
  end
end
