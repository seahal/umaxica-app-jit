# typed: false
# frozen_string_literal: true

module News
  module Org
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "news_org"
        end
      end
    end
  end
end
