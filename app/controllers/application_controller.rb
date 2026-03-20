# typed: false
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # FIXME: Resolve the URL issues before deploying.
  protect_from_forgery using: :header_or_legacy_token,
                       trusted_origins: %w(
                         http://sign.app.localhost
                         https://sign.app.localhost
                         http://sign.org.localhost
                         https://sign.org.localhost
                         http://app.localhost
                         https://app.localhost
                         http://org.localhost
                         https://org.localhost
                         http://com.localhost
                         https://com.localhost
                         http://www.app.localhost
                         https://www.app.localhost
                         http://www.org.localhost
                         https://www.org.localhost
                         http://www.com.localhost
                         https://www.com.localhost
                         http://docs.app.localhost
                         https://docs.app.localhost
                         http://docs.org.localhost
                         https://docs.org.localhost
                         http://docs.com.localhost
                         https://docs.com.localhost
                         http://news.app.localhost
                         https://news.app.localhost
                         http://news.org.localhost
                         https://news.org.localhost
                         http://news.com.localhost
                         https://news.com.localhost
                         http://help.app.localhost
                         https://help.app.localhost
                         http://help.org.localhost
                         https://help.org.localhost
                         http://help.com.localhost
                         https://help.com.localhost
                         http://www.example.com
                         https://www.example.com
                       ),
                       with: :exception
end
