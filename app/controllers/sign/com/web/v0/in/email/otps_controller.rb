# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Web
      module V0
        module In
          module Email
            class OtpsController < Sign::App::Web::V0::In::Email::OtpsController
              include Sign::Com::ControllerBehavior
            end
          end
        end
      end
    end
  end
end
