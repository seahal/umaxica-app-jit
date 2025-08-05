# frozen_string_literal: true

module Auth
  module App
    module Authentication
      class PasskeysController < ApplicationController
        include WebAuthn

        def new
          # WebAuthn credential creation options
        end

        def create
          # WebAuthn credential registration
        end

        private

        def passkey_params
          params.expect(passkey: [ :nickname, :credential_response ])
        end
      end
    end
  end
end
