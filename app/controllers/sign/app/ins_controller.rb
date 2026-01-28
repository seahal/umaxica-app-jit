# frozen_string_literal: true

module Sign::App
  class InsController < ApplicationController
    before_action :reject_logged_in_session

    def new
      session[:social_intent] = "login"
    end
  end
end
