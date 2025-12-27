# frozen_string_literal: true

module Auth
  module Org
    module Setting
      class PasskeysController < ApplicationController
        before_action :authenticate_staff!

        def index
          render_not_implemented
        end

        def new
          render_not_implemented
        end

        def edit
          render_not_implemented
        end

        def update
          render_not_implemented
        end

        private

        def render_not_implemented
          render plain: I18n.t("errors.not_implemented")
        end
      end
    end
  end
end
