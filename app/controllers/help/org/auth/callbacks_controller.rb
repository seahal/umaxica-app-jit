# typed: false
# frozen_string_literal: true

module Help
  module Org
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "help_org"
        end
      end
    end
  end
end
