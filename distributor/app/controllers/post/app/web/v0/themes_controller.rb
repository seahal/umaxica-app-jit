# typed: false
# frozen_string_literal: true

module Post
  module App
    module Web
      module V0
        class ThemesController < ApplicationController
          include ::Preference::WebThemeActions

          activate_web_theme_actions
        end
      end
    end
  end
end
