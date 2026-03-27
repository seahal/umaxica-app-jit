# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class WithdrawalsController < Sign::App::Configuration::WithdrawalsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
