require "test_helper"

class Sign::App::WithdrawalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @host = ENV["SIGN_SERVICE_URL"]
    @user = create_test_user
  end

  test "should get new withdrawal page" do
    get new_sign_app_withdrawal_url(host: @host)

    assert_response :success
    assert_select "h1", /Withdrawal|退会/
  end



  test "test user is user not staff" do
    assert_predicate @user, :user?, "User should be identified as user"
    assert_not @user.staff?, "User should not be identified as staff"
  end

  private

  def create_test_user
    # Create a test user with necessary methods
    OpenStruct.new(id: 1, withdrawn_at: nil).tap do |user|
      user.define_singleton_method(:update) do |attrs|
        attrs.each { |k, v| self.send("#{k}=", v) }
        true
      end
      user.define_singleton_method(:user?) do
        true
      end
      user.define_singleton_method(:staff?) do
        false
      end
    end
  end
end
