# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class HealthsController < Sign::App::HealthsController
      include Sign::Com::ControllerBehavior
    end
  end
end
