module Sign
  module Org
    module WithdrawalsHelper
      # Check if staff user is in withdrawn state
      def user_withdrawn?
        current_user&.withdrawn_at.present?
      end

      # Calculate days remaining for recovery (1 month = 30 days)
      def days_until_permanent_deletion
        return nil unless user_withdrawn?

        withdrawal_date = current_user.withdrawn_at
        recovery_deadline = withdrawal_date + 30.days
        days_remaining = ((recovery_deadline - Time.current) / 1.day).ceil

        [ days_remaining, 0 ].max # Don't return negative numbers
      end

      # Check if recovery period has expired
      def recovery_period_expired?
        return false unless user_withdrawn?

        Time.current >= current_user.withdrawn_at + 30.days
      end
    end
  end
end
