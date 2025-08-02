Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           Rails.application.credentials[:OMNI_AUTH][:GOOGLE][:CLIENT_ID],
           Rails.application.credentials[:OMNI_AUTH][:GOOGLE][:CLIENT_SECRET],
           {
             scope: "email,profile",
             state: true,
             callback_path: "/registration/google",
             setup: lambda do |env|
               strategy = env["omniauth.strategy"]
               request = Rack::Request.new(env)
               strategy.options.callback_url = "#{request.scheme}://#{request.host_with_port}/registration/google"
             end
           }
  provider :apple,
           Rails.application.credentials[:OMNI_AUTH][:APPLE][:CLIENT_ID],
           "",
           {
             scope: "email name",
             team_id: Rails.application.credentials[:OMNI_AUTH][:APPLE][:TEAM_ID],
             key_id: Rails.application.credentials[:OMNI_AUTH][:APPLE][:KEY_ID],
             pem: Rails.application.credentials[:OMNI_AUTH][:APPLE][:APPLE_PRIVATE_KEY],
             callback_path: "/registration/apple",
             setup: lambda do |env|
               strategy = env["omniauth.strategy"]
               request = Rack::Request.new(env)
               strategy.options.callback_url = "#{request.scheme}://#{request.host_with_port}/registration/apple"
             end
           }
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
