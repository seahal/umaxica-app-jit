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
    csrf_cookie_opts = {
      httponly: false,
      secure: Rails.env.production?,
      same_site: :lax,
      path: "/",
      expires: 1.day.from_now,
    }
    csrf_cookie_opts[:domain] = shared_cookie_domain if respond_to?(:shared_cookie_domain, true)
    cookies[CSRF_COOKIE_KEY] = csrf_cookie_opts.merge(value: token)

    # Client should call with credentials: "include" and send X-CSRF-Token on write requests.
    render json: { csrf_token: token }
  end

  private

  def shared_cookie_domain
    @shared_cookie_domain ||= resolve_cookie_domain if respond_to?(:resolve_cookie_domain, true)
  end
end
