module Cloudflare
  extend ActiveSupport::Concern

  private

  def cloudflare_turnstile_validation
    return { "success" => true } unless Rails.env.production?

    res = Net::HTTP.post_form(URI.parse("https://challenges.cloudflare.com/turnstile/v0/siteverify"),
                              { "secret" => ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"],
                                "response" => params["cf-turnstile-response"],
                                "remoteip" => request.remote_ip })

    JSON.parse(res.body)
  end
end
