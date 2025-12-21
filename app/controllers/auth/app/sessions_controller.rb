module Auth
  module App
    class SessionsController < ApplicationController
      def create
        # FIXME: write loggin code!
        render plain: I18n.t("common.ok")
      end
    end
  end
end
