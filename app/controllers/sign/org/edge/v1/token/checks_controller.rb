# frozen_string_literal: true

class Sign::Org::Edge::V1::Token::ChecksController < Sign::Org::Edge::V1::BaseController
  skip_before_action :set_preferences_cookie
  skip_before_action :transparent_refresh_access_token

  def show
    response.set_header("Cache-Control", "no-store")

    if logged_in?
      render json: { authenticated: true }, status: :ok
    else
      render json: { authenticated: false, error: "Unauthorized" }, status: :unauthorized
    end
  end
end
