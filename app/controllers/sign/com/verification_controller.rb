# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class VerificationController < Sign::App::VerificationController
      include Sign::Com::ControllerBehavior
    end
  end
end
