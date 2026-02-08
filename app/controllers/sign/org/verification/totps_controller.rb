# frozen_string_literal: true

class Sign::Org::Verification::TotpsController < Sign::Org::Verification::BaseController
  def new
    return unless require_reauth_session!
    return unless require_method_available!(:totp)
  end

  def create
    return unless require_reauth_session!
    return unless require_method_available!(:totp)

    if verify_totp!
      consume_reauth_session!
    else
      render :new, status: :unprocessable_content
    end
  end
end
