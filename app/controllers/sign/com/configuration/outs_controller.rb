# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class OutsController < Sign::App::Configuration::OutsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
