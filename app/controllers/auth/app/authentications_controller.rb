module Auth::App
  class AuthenticationsController < ApplicationController
    include ::Redirect
    include ::Authn

    def new
      raise if logged_in?
    end

    def edit
      # raise unless logged_in?
    end

    def destroy
      #raise unless logged_in?
      log_out

      # Redirect to login page
      flash[:success] = t("auth.registration.email.edit.you_have_already_logged_in")
      redirect_to new_auth_app_authentication_path, allow_other_host: true
    end
  end
end
