# frozen_string_literal: true

class Sign::App::VerificationController < Sign::App::Verification::BaseController
  def show
    @reauth_session = ReauthSession.new(
      scope: params[:scope].to_s,
      return_to: params[:return_to].to_s,
    )

    @reauth_sessions = ReauthSession.for_actor(@actor_token).recent_first.limit(50)
  end
end
