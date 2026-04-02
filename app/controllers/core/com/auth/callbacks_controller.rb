# typed: false
# frozen_string_literal: true

module Core
  module Com
    module Auth
      class CallbacksController < ApplicationController
        include ::Oidc::Callback

        private

        def oidc_client_id
          "main_com"
        end
      end
    end
  end
end
