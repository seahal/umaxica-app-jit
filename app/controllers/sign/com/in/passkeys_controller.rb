# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class PasskeysController < Sign::App::In::PasskeysController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
