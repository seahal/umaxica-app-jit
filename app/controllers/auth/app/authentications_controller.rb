module Auth::App
  class AuthenticationsController < ApplicationController
    include ::Redirect

    def new
      raise if signed_in?
    end

    def edit
      raise unless signed_in?
    end

    def destroy
      raise unless logged_in?
      # TODO: Implement!

      # Redirect to login page
      flash[:success] = "logged out!"
      redirect_to new_auth_app_authentication_path, allow_other_host: true
    end
  end
end
