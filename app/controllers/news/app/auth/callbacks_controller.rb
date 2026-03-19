# typed: false
# frozen_string_literal: true

module News
  module App
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "news_app"
        end
      end
    end
  end
end
