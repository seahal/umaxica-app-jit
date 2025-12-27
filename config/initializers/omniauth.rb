# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV["OMNI_AUTH_GOOGLE_CLIENT_ID"] || Rails.application.credentials.OMNI_AUTH.GOOGLE.CLIENT_ID,
           ENV["OMNI_AUTH_GOOGLE_CLIENT_SECRET"] || Rails.application.credentials.OMNI_AUTH.GOOGLE.CLIENT_SECRET,
           {
             callback_path: "/social/google/callback",
           }

  provider :apple,
           ENV["OMNI_AUTH_APPLE_CLIENT_ID"] || Rails.application.credentials.OMNI_AUTH.APPLE.CLIENT_ID,
           "",
           {
             scope: "email name",
             team_id: ENV["OMNI_AUTH_APPLE_TEAM_ID"] || Rails.application.credentials.OMNI_AUTH.APPLE.TEAM_ID,
             key_id: ENV["OMNI_AUTH_APPLE_KEY_ID"] || Rails.application.credentials.OMNI_AUTH.APPLE.KEY_ID,
             pem: ENV["OMNI_AUTH_APPLE_PEM"] || Rails.application.credentials.OMNI_AUTH.APPLE.PRIVATE_KEY,
             callback_path: "/social/apple/callback",
             provider_ignores_state: true,
           }
end
OmniAuth.config.allowed_request_methods = %i(post)
