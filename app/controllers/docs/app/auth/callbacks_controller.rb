# typed: false
# frozen_string_literal: true

module Docs
  module App
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "docs_app"
        end
      end
    end
  end
end
