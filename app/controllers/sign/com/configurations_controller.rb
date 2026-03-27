# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class ConfigurationsController < Sign::App::ConfigurationsController
      include Sign::Com::ControllerBehavior
    end
  end
end
