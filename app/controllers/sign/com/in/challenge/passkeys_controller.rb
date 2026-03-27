# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      module Challenge
        class PasskeysController < Sign::App::In::Challenge::PasskeysController
          include Sign::Com::ControllerBehavior
        end
      end
    end
  end
end
