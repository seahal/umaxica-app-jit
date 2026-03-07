# typed: false
# frozen_string_literal: true

module Preference
  module ConsentedBuffer
    extend ActiveSupport::Concern

    private

    # Write-only buffer cookie for JS. Rails must not read this cookie.
    def set_jit_preference_consented_buffer!(consented:, expires_at:)
      cookie_options = ::Core::CookieOptions.for(
        surface: ::Core::Surface.current(request),
        request: request,
        same_site: :lax,
        secure: Rails.env.production?,
        path: "/",
      )

      cookies[Preference::IoKeys::Cookies::CONSENTED] = {
        **cookie_options,
      }.merge(
        value: consented_cookie_value(consented),
        expires: expires_at,
        httponly: false,
      )
    end

    def consented_cookie_value(consented)
      ActiveModel::Type::Boolean.new.cast(consented) ? "1" : "0"
    end
  end
end
