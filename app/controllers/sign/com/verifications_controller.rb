# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class VerificationsController < Sign::App::VerificationsController
      include Sign::Com::ControllerBehavior
    end
  end
end
