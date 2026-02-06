# frozen_string_literal: true

module SocialCallbackTestHelper
  def self.callback_headers(host, origin: nil, referer: nil)
    origin ||= "http://#{host}"
    headers = { "Host" => host }
    headers["Origin"] = origin if origin
    headers["Referer"] = referer if referer
    headers
  end
end
