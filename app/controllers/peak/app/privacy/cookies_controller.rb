# frozen_string_literal: true

module Peak
  module App
    module Privacy
      class CookiesController < ApplicationController
        include ::Cookie
      end
    end
  end
end
