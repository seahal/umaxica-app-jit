# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class UpsController < Sign::App::UpsController
      include Sign::Com::ControllerBehavior
    end
  end
end
