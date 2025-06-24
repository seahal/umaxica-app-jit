module Authentication
  extend ActiveSupport::Concern

  # set url params

  private

  # generate uuid
  def logged_in?
    false
  end

  def check_authentication
    anonymous_id = 0
    user_id = 0
    staff_id = 0
    customer_id = 0
    last_mfa_time = nil
    refresh_token_expires_at = 1.years.from_now

    cookies.encrypted[:access_token] = {
      value: { id: nil, user_id:, staff_id:, created_at: Time.now, expires_at: nil },
      httponly: true,
      secure: Rails.env.production? ? true : false,
      expires: 30.seconds.from_now
    }
    cookies.encrypted[:refresh_token] = {
      value: { id: nil, user_id:, staff_id:, last_mfa_time:, created_at: Time.now, expires_at: refresh_token_expires_at },
      httponly: true,
      secure: Rails.env.production? ? true : false,
      expires: refresh_token_expires_at
    }
    cookies.signed[:identity_token] = {
      value: { account_ids: [], common_account_id: nil },
      httponly: false,
      secure: Rails.env.production? ? true : false,
      expires: refresh_token_expires_at
    }
  end
end
