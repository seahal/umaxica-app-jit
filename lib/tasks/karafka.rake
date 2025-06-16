# frozen_string_literal: true

namespace :karafka do
  desc "Setup Kafka topics for the application"
  task setup_topics: :environment do
    require 'kafka'

    begin
      kafka = Kafka.new(
        seed_brokers: ENV.fetch('KAFKA_BROKERS', 'localhost:9092').split(','),
        client_id: ENV.fetch('KAFKA_CLIENT_ID', 'umaxica-app')
      )

      # Define topics with their configurations
      topics = [
        { name: 'default', partitions: 3, replication_factor: 1 },
        { name: 'critical', partitions: 2, replication_factor: 1 },
        { name: 'mailers', partitions: 2, replication_factor: 1 },
        { name: 'user_events', partitions: 6, replication_factor: 1, config: { 'cleanup.policy' => 'compact' } },
        { name: 'notifications', partitions: 3, replication_factor: 1 },
        { name: 'audit_logs', partitions: 3, replication_factor: 1, config: { 'retention.ms' => '604800000' } },
        { name: 'example', partitions: 1, replication_factor: 1 }
      ]

      topics.each do |topic_config|
        topic_name = topic_config[:name]
        
        begin
          kafka.create_topic(
            topic_name,
            num_partitions: topic_config[:partitions],
            replication_factor: topic_config[:replication_factor],
            config: topic_config[:config] || {}
          )
          puts "✓ Created topic: #{topic_name}"
        rescue Kafka::TopicAlreadyExistsError
          puts "ℹ Topic already exists: #{topic_name}"
        rescue StandardError => e
          puts "✗ Failed to create topic #{topic_name}: #{e.message}"
        end
      end

      puts "\nTopics setup completed!"
      
    rescue StandardError => e
      puts "Error connecting to Kafka: #{e.message}"
      puts "Make sure Kafka is running and accessible at: #{ENV.fetch('KAFKA_BROKERS', 'localhost:9092')}"
      exit 1
    ensure
      kafka&.close
    end
  end

  desc "List all Kafka topics"
  task list_topics: :environment do
    require 'kafka'

    begin
      kafka = Kafka.new(
        seed_brokers: ENV.fetch('KAFKA_BROKERS', 'localhost:9092').split(','),
        client_id: ENV.fetch('KAFKA_CLIENT_ID', 'umaxica-app')
      )

      topics = kafka.topics
      puts "Available topics:"
      topics.each { |topic| puts "  - #{topic}" }
      
    rescue StandardError => e
      puts "Error connecting to Kafka: #{e.message}"
      exit 1
    ensure
      kafka&.close
    end
  end

  desc "Test Kafka connection"
  task test_connection: :environment do
    require 'kafka'

    begin
      kafka = Kafka.new(
        seed_brokers: ENV.fetch('KAFKA_BROKERS', 'localhost:9092').split(','),
        client_id: ENV.fetch('KAFKA_CLIENT_ID', 'umaxica-app')
      )

      # Try to fetch metadata
      kafka.brokers
      puts "✓ Successfully connected to Kafka brokers: #{ENV.fetch('KAFKA_BROKERS', 'localhost:9092')}"
      
    rescue StandardError => e
      puts "✗ Failed to connect to Kafka: #{e.message}"
      puts "Check if Kafka is running and accessible at: #{ENV.fetch('KAFKA_BROKERS', 'localhost:9092')}"
      exit 1
    ensure
      kafka&.close
    end
  end

  desc "Send a test message to the example topic"
  task test_producer: :environment do
    begin
      message_data = {
        message: "Test message from Rake task",
        timestamp: Time.current.iso8601,
        sender: "rake_task"
      }

      EventPublisher.publish_to_topic(:example, message_data)
      puts "✓ Test message sent to 'example' topic"
      
    rescue StandardError => e
      puts "✗ Failed to send test message: #{e.message}"
      exit 1
    end
  end

  desc "Show Karafka routes"
  task routes: :environment do
    puts "Karafka Routes:"
    puts "=" * 50
    
    KarafkaApp.routes.each do |route|
      puts "Topic: #{route.topic}"
      puts "  Consumer: #{route.consumer}"
      puts "  Active Job: #{route.active_job?}"
      
      if route.topic_config
        puts "  Configuration:"
        route.topic_config.each do |key, value|
          puts "    #{key}: #{value}"
        end
      end
      
      puts
    end
  end
end