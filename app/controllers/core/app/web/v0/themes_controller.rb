# typed: false
# frozen_string_literal: true

module Core
  module App
    module Web
      module V0
        class ThemesController < ApplicationController
          include ::Preference::WebThemeActions
        end
      end
    end
  end
end
