# typed: false
# frozen_string_literal: true

module Contact
  module InquiryContext
    MODES = %w(guest anonymous_member identified_member).freeze
    SURFACES = %w(app com org).freeze

    Context =
      Struct.new(:surface, :mode, :actor, keyword_init: true) do
        def guest?
          mode == "guest"
        end

        def anonymous_member?
          mode == "anonymous_member"
        end

        def identified_member?
          mode == "identified_member"
        end

        def authenticated?
          anonymous_member? || identified_member?
        end

        def app?
          surface == "app"
        end

        def com?
          surface == "com"
        end

        def org?
          surface == "org"
        end
      end

    module_function

    def build(surface:, current_user: nil, current_staff: nil, mode: nil)
      surface = normalize_surface(surface)
      mode = normalize_mode(mode) || infer_mode(current_user: current_user, current_staff: current_staff)

      Context.new(
        surface: surface,
        mode: mode,
        actor: resolve_actor(current_user: current_user, current_staff: current_staff),
      )
    end

    def normalize_surface(value)
      normalized = value.to_s
      return normalized if SURFACES.include?(normalized)

      raise ArgumentError, "unsupported inquiry surface: #{value.inspect}"
    end
    module_function :normalize_surface

    def normalize_mode(value)
      return nil if value.blank?

      normalized = value.to_s
      return normalized if MODES.include?(normalized)

      raise ArgumentError, "unsupported inquiry mode: #{value.inspect}"
    end
    module_function :normalize_mode

    def infer_mode(current_user:, current_staff:)
      return "identified_member" if current_user.present? || current_staff.present?

      "guest"
    end
    module_function :infer_mode

    def resolve_actor(current_user:, current_staff:)
      return current_user if current_user.present?
      return current_staff if current_staff.present?

      nil
    end
    module_function :resolve_actor
  end
end
