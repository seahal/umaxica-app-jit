# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class SessionsController < Sign::App::In::SessionsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
