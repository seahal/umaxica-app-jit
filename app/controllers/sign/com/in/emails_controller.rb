# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class EmailsController < Sign::App::In::EmailsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
