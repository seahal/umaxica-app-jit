# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Verification
      class TotpsController < Sign::App::Verification::TotpsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
