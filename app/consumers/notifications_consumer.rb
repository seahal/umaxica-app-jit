# frozen_string_literal: true

# Consumer for handling notification events
class NotificationsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      notification_data = JSON.parse(message.payload)
      
      case notification_data['type']
      when 'email'
        handle_email_notification(notification_data)
      when 'sms'
        handle_sms_notification(notification_data)
      when 'push'
        handle_push_notification(notification_data)
      when 'in_app'
        handle_in_app_notification(notification_data)
      else
        Rails.logger.warn "Unknown notification type: #{notification_data['type']}"
      end
    rescue JSON::ParserError => e
      Rails.logger.error "Failed to parse notification message: #{e.message}"
    rescue StandardError => e
      Rails.logger.error "Error processing notification: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end

  private

  def handle_email_notification(data)
    recipient = data['recipient']
    template = data['template']
    params = data['params'] || {}
    
    Rails.logger.info "Sending email notification to: #{recipient}, template: #{template}"
    
    # Add email sending logic here
    # e.g., NotificationMailer.send_template(recipient, template, params).deliver_later
  end

  def handle_sms_notification(data)
    phone_number = data['phone_number']
    message = data['message']
    
    Rails.logger.info "Sending SMS notification to: #{phone_number}"
    
    # Add SMS sending logic here
    # e.g., SmsService.send_message(phone_number, message)
  end

  def handle_push_notification(data)
    user_id = data['user_id']
    title = data['title']
    body = data['body']
    
    Rails.logger.info "Sending push notification to user: #{user_id}"
    
    # Add push notification logic here
    # e.g., PushNotificationService.send(user_id, title, body)
  end

  def handle_in_app_notification(data)
    user_id = data['user_id']
    content = data['content']
    category = data['category']
    
    Rails.logger.info "Creating in-app notification for user: #{user_id}, category: #{category}"
    
    # Add in-app notification creation logic here
    # e.g., InAppNotification.create(user_id: user_id, content: content, category: category)
  end
end