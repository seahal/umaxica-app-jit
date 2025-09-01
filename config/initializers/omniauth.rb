Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials[:OMNI_AUTH][:GOOGLE][:CLIENT_ID],
           Rails.application.credentials[:OMNI_AUTH][:GOOGLE][:CLIENT_SECRET]
  provider :apple,
           Rails.application.credentials[:OMNI_AUTH][:APPLE][:CLIENT_ID],
           "",
           { scope: "email name",
             team_id: Rails.application.credentials[:OMNI_AUTH][:APPLE]["TEAM_ID"],
             key_id: Rails.application.credentials[:OMNI_AUTH][:APPLE]["KEY_ID"],
             pem: Rails.application.credentials[:OMNI_AUTH][:APPLE]["PRIVATE_KEY"]
           }
end
OmniAuth.config.allowed_request_methods = %i[post]
