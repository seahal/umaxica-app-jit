# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class EmailsController < Sign::App::Configuration::EmailsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
