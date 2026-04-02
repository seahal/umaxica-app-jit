# typed: false
# frozen_string_literal: true

module Core
  module Org
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "core_org"
        end
      end
    end
  end
end
