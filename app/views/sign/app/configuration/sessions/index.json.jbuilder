json.sessions @sessions do |session|
  json.extract! session, :public_id, :created_at, :last_used_at, :user_token_kind_id
end
