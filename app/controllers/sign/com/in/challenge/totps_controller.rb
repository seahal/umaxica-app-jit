# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      module Challenge
        class TotpsController < Sign::App::In::Challenge::TotpsController
          include Sign::Com::ControllerBehavior
        end
      end
    end
  end
end
