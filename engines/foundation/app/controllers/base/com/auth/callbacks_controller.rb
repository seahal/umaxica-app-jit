# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Com
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "base_com"
            end
          end
        end
      end
    end
  end
end
