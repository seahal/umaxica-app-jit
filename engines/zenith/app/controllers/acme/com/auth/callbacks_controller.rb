# typed: false
# frozen_string_literal: true

module Jit
  module Zenith
    module Acme
      module Com
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "acme_com"
            end
          end
        end
      end
    end
  end
end
