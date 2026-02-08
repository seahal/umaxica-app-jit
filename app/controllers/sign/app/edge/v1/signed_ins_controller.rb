# frozen_string_literal: true

class Sign::App::Edge::V1::SignedInsController < Sign::App::Edge::V1::BaseController
  include Sign::Edge::TokenAuthenticatable

  skip_before_action :set_preferences_cookie
  skip_before_action :transparent_refresh_access_token

  def show
    response.set_header("Cache-Control", "no-store")
    render json: { signed_in: true }, status: :ok
  end
end
