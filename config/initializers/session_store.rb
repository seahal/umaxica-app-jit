Rails.application.config.session_store :cookie_store,
                                       expire_after: 12.hours,
                                       key: Rails.env.production? ? "__Secure-jit_session" : "jit_session",
                                       secure: Rails.env.production?,
                                       httponly: true,
                                       same_site: :lax
