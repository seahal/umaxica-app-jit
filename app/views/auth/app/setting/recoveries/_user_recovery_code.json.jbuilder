json.extract! user_recovery_code, :id, :user_id, :recovery_code_digest, :expires_in, :created_at, :updated_at
json.url auth_app_setting_recovery_url(user_recovery_code, format: :json)