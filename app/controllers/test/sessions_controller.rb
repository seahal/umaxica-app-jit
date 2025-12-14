module Test
  class SessionsController < ApplicationController
    def create_staff
      session[:staff] = params[:id]
      head :ok
    end
  end
end
