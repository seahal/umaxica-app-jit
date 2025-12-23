module Cookie
  extend ActiveSupport::Concern

  def edit
    @accept_functional_cookies = cookies.signed[:accept_functional_cookies] || false
    @accept_performance_cookies = cookies.signed[:accept_performance_cookies] || false
    @accept_targeting_cookies = cookies.signed[:accept_targeting_cookies] || false
  end

  def update
    cookies.permanent.signed[:accept_functional_cookies] = params[:accept_functional_cookies] == "1"
    cookies.permanent.signed[:accept_performance_cookies] = params[:accept_performance_cookies] == "1"
    cookies.permanent.signed[:accept_targeting_cookies] = params[:accept_targeting_cookies] == "1"
    redirect_to action: :edit
  end
end
