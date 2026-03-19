# typed: false
# frozen_string_literal: true

module Docs
  module Org
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "docs_org"
        end
      end
    end
  end
end
