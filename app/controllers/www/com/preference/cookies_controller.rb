module Www
  module Com
    module Preference
      class CookiesController < ApplicationController
        include ::Cookie
      end
    end
  end
end
