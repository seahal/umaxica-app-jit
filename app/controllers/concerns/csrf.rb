# frozen_string_literal: true

module Csrf
  extend ActiveSupport::Concern

  CSRF_COOKIE_KEY = Rails.env.production? ? "__Secure-jit_csrf_token" : "jit_csrf_token"

  included do
    public_strict! if respond_to?(:public_strict!)
  end

  def show
    response.set_header("Cache-Control", "no-store")

    token = form_authenticity_token

    # Set CSRF token as non-HttpOnly cookie (SameSite=Lax, Secure in prod)
    # Non-HttpOnly: so React can read it from JavaScript
    csrf_cookie_opts = Core::CookieOptions.for(
      surface: Core::Surface.current(request),
      request: request,
      httponly: false,
      secure: Rails.env.production?,
      same_site: :lax,
      path: "/",
      expires: 1.day.from_now,
    )
    cookies[CSRF_COOKIE_KEY] = csrf_cookie_opts.merge(value: token)

    # Client should call with credentials: "include" and send X-CSRF-Token on write requests.
    render json: { csrf_token: token }
  end
end
