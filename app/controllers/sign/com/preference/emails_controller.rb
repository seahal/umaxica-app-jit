# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Preference
      class EmailsController < Sign::App::Preference::EmailsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
