# typed: false
# frozen_string_literal: true

module News
  module Com
    module Web
      module V0
        class CookiesController < ApplicationController
          include ::Preference::WebCookieActions
        end
      end
    end
  end
end
