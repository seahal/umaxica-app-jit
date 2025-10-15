module CloudflareTurnstile
  extend ActiveSupport::Concern

  private

  def cloudflare_turnstile_validation
    return { "success" => true } if Rails.env.test?

    res = Net::HTTP.post_form(URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
                              { "secret" => Rails.application.credentials.dig(:CLOUDFLARE, :TURNSTILE_SECRET_KEY),
                                "response" => params["cf-turnstile-response"],
                                "remoteip" => request.remote_ip })

    JSON.parse(res.body)
  end
end
