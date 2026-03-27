# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class TotpsController < Sign::App::Configuration::TotpsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
