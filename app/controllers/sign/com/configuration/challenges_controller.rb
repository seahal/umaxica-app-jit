# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Configuration
      class ChallengesController < Sign::App::Configuration::ChallengesController
        include Sign::Com::ControllerBehavior
      end
    end
  end
end
