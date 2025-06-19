# frozen_string_literal: true

class MailersConsumer < ApplicationConsumer
  def consume
    config(partitions: 1, replication_factor: 1)
    messages.each do |message|
      Email::App::EmailRegistrationMailer.with(email_address:'m.shiihara@gmail.com').create.deliver_now
      @message = message
      puts @message.payload
      puts "a" * 100
      mark_as_consumed(@message)
    end
  end
end
