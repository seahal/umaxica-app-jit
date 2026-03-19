# typed: false
# frozen_string_literal: true

module Apex
  module Org
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "apex_org"
        end
      end
    end
  end
end
