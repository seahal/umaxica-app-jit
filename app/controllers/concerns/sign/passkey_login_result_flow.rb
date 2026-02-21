# frozen_string_literal: true

module Sign
  module PasskeyLoginResultFlow
    extend ActiveSupport::Concern

    private

    def handle_login_result(result)
      return if handle_domain_specific_login_status(result)
      return render_passkey_success(result) if result[:status] == :success

      render_error("errors.login_failed", :unprocessable_content)
    end

    def render_passkey_success(result)
      if passkey_success_restricted?(result)
        return render_passkey_restricted_success(result)
      end

      issue_checkpoint!
      render json: {
        status: "ok",
        access_token: result[:access_token],
        token_type: result[:token_type],
        expires_in: result[:expires_in],
        redirect_url: passkey_checkpoint_redirect_url,
      }, status: :ok
    end

    def handle_domain_specific_login_status(_result)
      false
    end

    def passkey_success_restricted?(_result)
      false
    end

    def render_passkey_restricted_success(_result)
      raise NotImplementedError, "#{self.class} must define #render_passkey_restricted_success"
    end

    def passkey_checkpoint_redirect_url
      raise NotImplementedError, "#{self.class} must define #passkey_checkpoint_redirect_url"
    end
  end
end
