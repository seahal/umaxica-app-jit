module Root
  module App
    module Preference
      class ThemesController < ApplicationController
        include ::Theme
      end
    end
  end
end
