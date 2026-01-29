# frozen_string_literal: true

require "test_helper"

class I18nDebugTest < ActiveSupport::TestCase
  test "lookup debug" do
    I18n.with_locale(:ja) do
      puts "DEBUG: ja.errors.otp_locked = #{I18n.t("errors.otp_locked")}"
      puts "DEBUG: ja.sign.app.configuration.show.logout = #{I18n.t("sign.app.configuration.show.logout")}"
    end

    I18n.with_locale(:en) do
      puts "DEBUG: en.sign.app.reauth_sessions.index.title = #{I18n.t("sign.app.reauth_sessions.index.title")}"
    end
  end
end
