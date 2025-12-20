Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
          ENV["OMNI_AUTH_GOOGLE_CLIENT_ID"] || Rails.application.credentials.OMNI_AUTH.GOOGLE.CLIENT_ID,
          ENV["OMNI_AUTH_GOOGLE_CLIENT_SECRET"] || Rails.application.credentials.OMNI_AUTH.GOOGLE.CLIENT_SECRET,
          {
            callback_path: "/social/google/callback"
          }

  provider :apple,
           Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :CLIENT_ID),
           "",
           {
             scope: "email name",
             team_id: Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :TEAM_ID),
             key_id:  Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :KEY_ID),
             pem:     Rails.application.credentials.dig(:OMNI_AUTH, :APPLE, :PRIVATE_KEY),
             callback_path: "/social/apple/callback"
           }
end
OmniAuth.config.allowed_request_methods = %i[post]
