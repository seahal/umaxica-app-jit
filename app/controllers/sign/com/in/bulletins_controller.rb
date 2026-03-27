# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class BulletinsController < Sign::App::In::BulletinsController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
