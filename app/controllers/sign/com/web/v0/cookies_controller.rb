# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Web
      module V0
        class CookiesController < Sign::App::Web::V0::CookiesController
          include Sign::Com::ControllerBehavior
        end
      end
    end
  end
end
