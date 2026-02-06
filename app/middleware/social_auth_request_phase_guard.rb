# frozen_string_literal: true

class SocialAuthRequestPhaseGuard
  def initialize(app)
    @app = app
  end

  def call(env)
    rejection = SocialCallbackGuard.verify_request_phase!(env)
    return rejection if rejection

    @app.call(env)
  end
end
