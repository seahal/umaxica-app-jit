# typed: false
# frozen_string_literal: true

module Sign
  module Com
    module Web
      module V0
        class ThemesController < Sign::App::Web::V0::ThemesController
          include Sign::Com::ControllerBehavior
        end
      end
    end
  end
end
