# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class ActivitiesController < Sign::App::Configuration::ActivitiesController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
