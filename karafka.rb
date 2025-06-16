# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    # Kafka broker configuration
    config.kafka = {
      'bootstrap.servers': ENV.fetch('KAFKA_BROKERS', '127.0.0.1:9092'),
      'security.protocol': ENV.fetch('KAFKA_SECURITY_PROTOCOL', 'PLAINTEXT'),
      'group.id': ENV.fetch('KAFKA_GROUP_ID', 'umaxica-app'),
      'auto.offset.reset': 'earliest',
      'enable.auto.commit': false,
      'session.timeout.ms': 30000,
      'heartbeat.interval.ms': 10000
    }
    
    # Application identification
    config.client_id = ENV.fetch('KAFKA_CLIENT_ID', 'umaxica-app')
    
    # Recreate consumers with each batch in development for code reload
    config.consumer_persistence = !Rails.env.development?
    
    # Concurrency settings
    config.max_messages = 100
    config.max_wait_time = 1000 # 1 second
    
    # Error handling
    config.pause_timeout = 10_000 # 10 seconds
    config.pause_max_timeout = 30_000 # 30 seconds
    config.pause_with_exponential_backoff = true
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  Karafka.monitor.subscribe(
    Karafka::Instrumentation::LoggerListener.new(
      # Karafka, when the logger is set to info, produces logs each time it polls data from an
      # internal messages queue. This can be extensive, so you can turn it off by setting below
      # to false.
      log_polling: true
    )
  )
  # Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)

  # This logger prints the producer development info using the Karafka logger.
  # It is similar to the consumer logger listener but producer oriented.
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(
      # Log producer operations using the Karafka logger
      Karafka.logger,
      # If you set this to true, logs will contain each message details
      # Please note, that this can be extensive
      log_messages: false
    )
  )

  # You can subscribe to all consumer related errors and record/track them that way
  #
  # Karafka.monitor.subscribe 'error.occurred' do |event|
  #   type = event[:type]
  #   error = event[:error]
  #   details = (error.backtrace || []).join("\n")
  #   ErrorTracker.send_error(error, type, details)
  # end

  # You can subscribe to all producer related errors and record/track them that way
  # Please note, that producer and consumer have their own notifications pipeline so you need to
  # setup error tracking independently for each of them
  #
  # Karafka.producer.monitor.subscribe('error.occurred') do |event|
  #   type = event[:type]
  #   error = event[:error]
  #   details = (error.backtrace || []).join("\n")
  #   ErrorTracker.send_error(error, type, details)
  # end

  routes.draw do
    # ActiveJob integration for background job processing
    active_job_topic :default do
      config(partitions: 3, replication_factor: 1)
    end
    
    active_job_topic :critical do
      config(partitions: 2, replication_factor: 1)
    end
    
    active_job_topic :mailers do
      config(partitions: 2, replication_factor: 1)
    end
    
    # Application-specific topics
    topic :user_events do
      config(partitions: 6, replication_factor: 1, 'cleanup.policy': 'compact')
      consumer UserEventsConsumer
    end
    
    topic :notifications do
      config(partitions: 3, replication_factor: 1)
      consumer NotificationsConsumer
    end
    
    topic :audit_logs do
      config(partitions: 3, replication_factor: 1, 'retention.ms': 604800000) # 7 days
      consumer AuditLogsConsumer
    end
    
    # Example consumer for development/testing
    topic :example do
      config(partitions: 1, replication_factor: 1)
      consumer ExampleConsumer
    end
  end
end

# Karafka now features a Web UI!
# Visit the setup documentation to get started and enhance your experience.
#
# https://karafka.io/docs/Web-UI-Getting-Started
