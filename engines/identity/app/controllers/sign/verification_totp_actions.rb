# typed: false
# frozen_string_literal: true

module Jit
  module Identity
    module Sign
      module VerificationTotpActions
        extend ActiveSupport::Concern

        def new
          return unless require_reauth_session!
          return if redirect_if_recent_verification_for_get!

          nil unless require_method_available!(:totp)
        end

        def create
          return unless require_reauth_session!
          return if redirect_if_recent_verification_for_post!
          return unless require_method_available!(:totp)

          if verify_totp!
            consume_reauth_session!
          else
            render :new, status: :unprocessable_content
          end
        end
      end
    end
  end
end
