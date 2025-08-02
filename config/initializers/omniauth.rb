Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 
           Rails.application.credentials[:OMNI_AUTH][:GOOGLE][:CLIENT_ID], 
           Rails.application.credentials[:OMNI_AUTH][:GOOGLE][:CLIENT_SECRET],
           {
             callback_path: '/registration/google',
             setup: lambda do |env|
               strategy = env['omniauth.strategy']
               strategy.options.callback_url = "http://www.app.localhost:3000/registration/google"
             end
           }
end
