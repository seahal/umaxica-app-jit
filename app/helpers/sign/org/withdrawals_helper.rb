module Sign
  module Org
    module WithdrawalsHelper
      # Check if staff user is in withdrawn state
      def user_withdrawn?
        current_staff&.withdrawn?
      end

      # Calculate days remaining for recovery
      def days_until_permanent_deletion
        return nil unless user_withdrawn?

        recovery_deadline = current_staff.recovery_deadline
        return 0 unless recovery_deadline

        days_remaining = ((recovery_deadline - Time.current) / 1.day).ceil
        [ days_remaining, 0 ].max
      end

      # Check if recovery period has expired
      def recovery_period_expired?
        return false unless user_withdrawn?

        current_staff.recovery_deadline.present? && Time.current >= current_staff.recovery_deadline
      end
    end
  end
end
