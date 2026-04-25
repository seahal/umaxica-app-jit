# typed: false
# frozen_string_literal: true

module Jit
  module Foundation
    module Base
      module App
        class ConfigurationsController < Jit::Foundation::Base::App::ApplicationController
          auth_required!

          def show
          end
        end
      end
    end
  end
end
