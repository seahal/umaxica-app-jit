module Www
  module App
    module Preference
      class CookiesController < ApplicationController
        include ::Cookie
      end
    end
  end
end
