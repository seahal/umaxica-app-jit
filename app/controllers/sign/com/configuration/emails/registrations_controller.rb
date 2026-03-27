# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      module Emails
        class RegistrationsController < Sign::App::Configuration::Emails::RegistrationsController
          include Sign::Com::ControllerBehavior
        end
      end
    end
  end
end
