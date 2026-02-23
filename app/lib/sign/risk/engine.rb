# typed: false
# frozen_string_literal: true

module Sign
  module Risk
    class Engine
      # Returns integer score 0..100
      def self.score(user_id)
        return 0 unless user_id
        return 0 unless defined?(REDIS_CLIENT)

        key = "sign:risk:events:#{user_id}"
        # Look back 5 minutes
        now = Time.current.to_f
        five_min_ago = now - 5.minutes.to_f

        # zrangebyscore returns array of strings (JSON)
        events_json = REDIS_CLIENT.zrangebyscore(key, five_min_ago, "+inf")
        events = events_json.map { |j| JSON.parse(j) }

        # Rule 1: Refresh Token Reuse Detected -> 100
        # "refresh_reuse_detected"
        if events.any? { |e| e["name"] == "refresh_reuse_detected" }
          return 100
        end

        # Rule 2: Auth Failed short time (e.g. 5 times in 5 mins) -> 60
        auth_failures = events.count { |e| e["name"] == "auth_failed" }
        if auth_failures >= 5
          return 60
        end

        # Rule 3: Refresh Failed short time -> 40
        refresh_failures = events.count { |e| e["name"] == "refresh_failed" }
        if refresh_failures >= 5
          return 40
        end

        0
      end
    end
  end
end
