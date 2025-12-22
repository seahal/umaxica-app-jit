require "test_helper"

module Auth
  class WithdrawalErrorTest < ActiveSupport::TestCase
    test "WithdrawalError initializes with i18n key and status code" do
      error = WithdrawalError.new("sign.withdrawal.test", :bad_request)

      assert_equal "sign.withdrawal.test", error.i18n_key
      assert_equal :bad_request, error.status_code
    end
  end
end
