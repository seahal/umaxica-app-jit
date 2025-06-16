# frozen_string_literal: true

# Consumer for handling user-related events
class UserEventsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      event_data = JSON.parse(message.payload)
      
      case event_data['event_type']
      when 'user_created'
        handle_user_created(event_data)
      when 'user_updated'
        handle_user_updated(event_data)
      when 'user_deleted'
        handle_user_deleted(event_data)
      when 'login_attempt'
        handle_login_attempt(event_data)
      else
        Rails.logger.warn "Unknown user event type: #{event_data['event_type']}"
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse user event message: #{e.message}"
      # Don't re-raise to avoid infinite retry loop
    rescue StandardError => e
      Rails.logger.error "Error processing user event: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise # Re-raise to trigger retry mechanism
    end
  end

  private

  def handle_user_created(event_data)
    user_id = event_data['user_id']
    Rails.logger.info "Processing user created event for user: #{user_id}"
    
    # Add user creation side effects here
    # e.g., send welcome email, create user profile, etc.
  end

  def handle_user_updated(event_data)
    user_id = event_data['user_id']
    changes = event_data['changes']
    Rails.logger.info "Processing user updated event for user: #{user_id}, changes: #{changes}"
    
    # Add user update side effects here
    # e.g., sync with external services, update search index, etc.
  end

  def handle_user_deleted(event_data)
    user_id = event_data['user_id']
    Rails.logger.info "Processing user deleted event for user: #{user_id}"
    
    # Add user deletion side effects here
    # e.g., cleanup data, notify services, etc.
  end

  def handle_login_attempt(event_data)
    user_id = event_data['user_id']
    success = event_data['success']
    ip_address = event_data['ip_address']
    
    Rails.logger.info "Processing login attempt for user: #{user_id}, success: #{success}, IP: #{ip_address}"
    
    # Add login tracking logic here
    # e.g., fraud detection, analytics, etc.
  end
end