# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Preference
      class EmailController < Sign::App::Preference::EmailController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
