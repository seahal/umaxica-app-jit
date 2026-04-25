# typed: false
# frozen_string_literal: true

module Jit
  module Distributor
    module Post
      module Org
        module Auth
          class CallbacksController < ApplicationController
            include ::Oidc::Callback

            private

            def oidc_client_id
              "post_org"
            end
          end
        end
      end
    end
  end
end
