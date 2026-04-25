# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Org
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "base_org"
            end
          end
        end
      end
    end
  end
end
