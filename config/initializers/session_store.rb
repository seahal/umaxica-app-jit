Rails.application.config.session_store :cookie_store,
                                       expire_after: 12.hours,
                                       key: "__Secure_jit_session",
                                       secure: Rails.env.production? ? true : false,
                                       httponly: true
#                                        same_site: :lax,
#                                        domain: nil,
#                                        path: "/"if Rails.env.production?
