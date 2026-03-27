# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      module Telephones
        class RegistrationsController < Sign::App::Configuration::Telephones::RegistrationsController
          include Sign::Com::ControllerBehavior
        end
      end
    end
  end
end
