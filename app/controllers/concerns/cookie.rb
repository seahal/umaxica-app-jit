# frozen_string_literal: true

module Cookie
  extend ActiveSupport::Concern

  def edit
    @accept_tracking_cookies = cookies.signed[:accept_tracking_cookies] || false
  end

  def update
    cookies.permanent.signed[:accept_tracking_cookies] = params[:accept_tracking_cookies] == "1" ? true : false
    redirect_to edit_apex_app_preference_cookie_path
  end
end
