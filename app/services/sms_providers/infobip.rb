# frozen_string_literal: true

module SmsProviders
  class Infobip < Base
    def send_message(to:, message:, subject: nil)
      validate_params(to: to, message: message, subject: subject)

      response = http_client.post(
        "#{base_url}/sms/2/text/advanced",
        body: {
          messages: [
            {
              destinations: [ { to: to } ],
              from: sender_id,
              text: message
            }
          ]
        }.to_json,
        headers: {
          "Authorization" => "App #{api_key}",
          "Content-Type" => "application/json",
          "Accept" => "application/json"
        }
      )

      handle_response(response)
    end

    private

    def base_url
      Rails.application.credentials.dig(:INFOBIP_BASE_URL) || "https://api.infobip.com"
    end

    def api_key
      Rails.application.credentials.dig(:INFOBIP_API_KEY)
    end

    def sender_id
      Rails.application.credentials.dig(:INFOBIP_SENDER_ID) || "SMS"
    end

    def http_client
      @http_client ||= Net::HTTP
    end

    def handle_response(response)
      if response.code.to_i.between?(200, 299)
        JSON.parse(response.body)
      else
        raise "Infobip SMS failed: #{response.code} #{response.body}"
      end
    end
  end
end
