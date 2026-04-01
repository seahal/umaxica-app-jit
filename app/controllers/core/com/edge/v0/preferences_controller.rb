# typed: false
# frozen_string_literal: true

module Core
  module Com
    module Edge
      module V0
        class PreferencesController < ApplicationController
          include ::Preference::Edge
        end
      end
    end
  end
end
