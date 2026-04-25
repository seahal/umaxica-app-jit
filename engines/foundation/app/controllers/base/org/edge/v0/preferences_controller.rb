# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module Org
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
  end
end
