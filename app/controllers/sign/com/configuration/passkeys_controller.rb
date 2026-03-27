# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class PasskeysController < Sign::App::Configuration::PasskeysController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
