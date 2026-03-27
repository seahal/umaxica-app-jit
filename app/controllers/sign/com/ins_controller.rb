# typed: false
# frozen_string_literal: true

module Sign
  module Com
    class InsController < Sign::App::InsController
      include Sign::Com::ControllerBehavior
    end
  end
end
