# typed: false
# frozen_string_literal: true

# INFORMATION: Look this docs. https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html

# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :actor
  attribute :actor_type
  attribute :session
  attribute :token

  def user?
    actor_type == :user
  end

  def staff?
    actor_type == :staff
  end

  def admin?
    actor_type == :admin
  end

  def client?
    actor_type == :client
  end
end
