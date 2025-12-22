module Csrf
  extend ActiveSupport::Concern

  def show
    response.set_header("Cache-Control", "no-store")
    render json: { csrf_token: form_authenticity_token }
  end
end
