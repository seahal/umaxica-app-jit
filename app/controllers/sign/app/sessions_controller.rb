# typed: false
# frozen_string_literal: true

module Sign
  module App
    class SessionsController < ApplicationController
      def create
        Rails.event.notify("sign.app.session.created", remote_ip: request.remote_ip)
        render plain: I18n.t("common.ok")
      end
    end
  end
end
