# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module In
      class ChallengesController < Sign::App::In::ChallengesController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
