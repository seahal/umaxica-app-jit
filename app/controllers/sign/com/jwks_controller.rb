# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class JwksController < Sign::App::JwksController
      include Sign::Com::ControllerBehavior
    end
  end
end
