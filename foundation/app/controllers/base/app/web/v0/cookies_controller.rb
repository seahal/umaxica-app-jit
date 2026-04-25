# typed: false
# frozen_string_literal: true

module Base
  module App
    module Web
      module V0
        class CookiesController < ApplicationController
          include ::Preference::WebCookieActions

          activate_web_cookie_actions
        end
      end
    end
  end
end
