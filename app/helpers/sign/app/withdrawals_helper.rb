# frozen_string_literal: true

module Sign
  module App
    module WithdrawalsHelper
      # Check if user is in withdrawn state
      def user_withdrawn?
        current_user&.pre_withdrawal_condition? || current_user&.withdrawn?
      end

      # Calculate days remaining for recovery
      def days_until_permanent_deletion
        return nil unless current_user&.pre_withdrawal_condition?

        scheduled_at = current_user.withdraw_scheduled_at
        return 0 unless scheduled_at

        days_remaining = ((scheduled_at - Time.current) / 1.day).ceil
        [ days_remaining, 0 ].max
      end

      # Check if recovery period has expired
      def recovery_period_expired?
        return false unless current_user&.pre_withdrawal_condition?

        current_user.withdraw_scheduled_at.present? && Time.current >= current_user.withdraw_scheduled_at
      end
    end
  end
end
