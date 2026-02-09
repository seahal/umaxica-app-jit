# frozen_string_literal: true

class Sign::Org::Verification::PasskeysController < Sign::Org::Verification::BaseController
  def new
    return unless require_reauth_session!
    return if redirect_if_recent_verification_for_get!
    return unless require_method_available!(:passkey)

    prepare_passkey_challenge!
  end

  def create
    return unless require_reauth_session!
    return if redirect_if_recent_verification_for_post!
    return unless require_method_available!(:passkey)

    if verify_passkey!
      consume_reauth_session!
    else
      prepare_passkey_challenge!
      render :new, status: :unprocessable_content
    end
  end
end
