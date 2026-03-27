# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class TokensController < Sign::App::TokensController
      include Sign::Com::ControllerBehavior
    end
  end
end
