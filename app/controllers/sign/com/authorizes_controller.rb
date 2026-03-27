# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class AuthorizesController < Sign::App::AuthorizesController
      include Sign::Com::ControllerBehavior
    end
  end
end
