# frozen_string_literal: true

json.sessions @sessions do |session|
  json.public_id session.public_id
  json.created_at session.created_at
  json.last_active_at session.updated_at
  json.current session.public_id == current_session_public_id
end
