# typed: false
# frozen_string_literal: true

module Base
  module Com
    module Edge
      module V0
        class PreferencesController < ApplicationController
          include ::Preference::Edge

          activate_preference_edge
        end
      end
    end
  end
end
