# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class TelephonesController < Sign::App::Configuration::TelephonesController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
