# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class SessionsController < Sign::App::Configuration::SessionsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
