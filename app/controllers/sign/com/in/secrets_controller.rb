# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class SecretsController < Sign::App::In::SecretsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
