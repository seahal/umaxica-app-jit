# typed: false
# frozen_string_literal: true

# INFORMATION: Look this docs. https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html

# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :actor
  attribute :actor_type
  attribute :session
  attribute :token

  # TODO: return :org, :app or :com
  def domain
  end

  def user?
    actor_type == :user
  end

  def staff?
    actor_type == :staff
  end

  def operator?
    actor_type == :operator
  end

  def member?
    actor_type == :member
  end

  def actor
    raise
  end

  # TODO: i want to use Current.preference.cookie.functional -> true,false,nil -> Current.preference.timezone -> utc,jst,nil  Current.preference.language -> ja,en,nil
end
