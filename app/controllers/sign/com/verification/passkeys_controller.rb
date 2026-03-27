# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Verification
      class PasskeysController < Sign::App::Verification::PasskeysController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
