# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class SecretsController < Sign::App::Configuration::SecretsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
