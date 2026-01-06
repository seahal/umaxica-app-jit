# frozen_string_literal: true

module Sign::App
  class InsController < ApplicationController
    include ::Redirect

    def new
      raise AlreadyAuthenticatedError, "User is already logged in" if logged_in?
    end
  end
end
