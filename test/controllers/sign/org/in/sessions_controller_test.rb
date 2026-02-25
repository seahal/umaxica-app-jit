# typed: false
# frozen_string_literal: true

require "test_helper"

class Sign::Org::In::SessionsControllerTest < ActionDispatch::IntegrationTest
  test "show without gate redirects to login with alert" do
    get sign_org_in_session_url(ri: "jp"),
        headers: browser_headers.merge("Host" => "sign.org.localhost")

    assert_redirected_to new_sign_org_in_url
    assert_equal I18n.t("session_limit.gate_expired", default: "操作がタイムアウトしました。もう一度ログインしてください。"), flash[:alert]
  end

  test "show with gate but no pending staff redirects to login" do
    Sign::Org::In::SessionsController.any_instance.stub(:valid_gate?, true) do
      get sign_org_in_session_url(ri: "jp"),
          headers: browser_headers.merge("Host" => "sign.org.localhost")

      assert_redirected_to new_sign_org_in_url
      assert_equal I18n.t("session_limit.staff_not_found", default: "スタッフが見つかりません。もう一度ログインしてください。"),
                   flash[:alert]
    end
  end

  test "show with gate and pending staff displays active sessions" do
    staff = staffs(:one)
    staff.staff_tokens.create!(
      refresh_token_digest: "testtoken", revoked_at: nil,
      refresh_expires_at: 1.day.from_now,
    )

    Sign::Org::In::SessionsController.any_instance.stub(:valid_gate?, true) do
      Sign::Org::In::SessionsController.any_instance.stub(:load_pending_staff, staff) do
        get sign_org_in_session_url(ri: "jp"),
            headers: browser_headers.merge("Host" => "sign.org.localhost")

        assert_response :success
      end
    end
  end

  test "update without selections flashes alert and re-renders show" do
    staff = staffs(:one)
    staff.staff_tokens.create!(
      refresh_token_digest: "testtoken", revoked_at: nil,
      refresh_expires_at: 1.day.from_now,
    )

    Sign::Org::In::SessionsController.any_instance.stub(:valid_gate?, true) do
      Sign::Org::In::SessionsController.any_instance.stub(:load_pending_staff, staff) do
        patch sign_org_in_session_url(ri: "jp"),
              params: { revoke_session_ids: [] },
              headers: browser_headers.merge("Host" => "sign.org.localhost")

        assert_response :unprocessable_content
        assert_equal I18n.t("session_limit.no_sessions_selected", default: "無効化するセッションを選択してください。"),
                     flash[:alert]
      end
    end
  end

  test "update with selections revokes sessions, consumes gate and redirects to return_to" do
    staff = staffs(:one)
    token = staff.staff_tokens.create!(
      refresh_token_digest: "testtoken", revoked_at: nil,
      refresh_expires_at: 1.day.from_now,
    )

    Sign::Org::In::SessionsController.any_instance.stub(:valid_gate?, true) do
      Sign::Org::In::SessionsController.any_instance.stub(:load_pending_staff, staff) do
        Sign::Org::In::SessionsController.any_instance.stub(:session_limit_return_to, "/some/path") do
          patch sign_org_in_session_url(ri: "jp"),
                params: { revoke_session_ids: [token.id] },
                headers: browser_headers.merge("Host" => "sign.org.localhost")

          assert_redirected_to "/some/path"
          assert_equal I18n.t("session_limit.sessions_revoked", default: "セッションを無効化しました。ログインを続行してください。"),
                       flash[:notice]
          assert_not_nil token.reload.revoked_at
        end
      end
    end
  end

  test "update drops to login path if no return_to is set" do
    staff = staffs(:one)
    token = staff.staff_tokens.create!(
      refresh_token_digest: "testtoken", revoked_at: nil,
      refresh_expires_at: 1.day.from_now,
    )

    Sign::Org::In::SessionsController.any_instance.stub(:valid_gate?, true) do
      Sign::Org::In::SessionsController.any_instance.stub(:load_pending_staff, staff) do
        Sign::Org::In::SessionsController.any_instance.stub(:session_limit_return_to, nil) do
          patch sign_org_in_session_url(ri: "jp"),
                params: { revoke_session_ids: [token.id] },
                headers: browser_headers.merge("Host" => "sign.org.localhost")

          assert_redirected_to new_sign_org_in_url
          assert_equal I18n.t("session_limit.sessions_revoked", default: "セッションを無効化しました。ログインを続行してください。"),
                       flash[:notice]
          assert_not_nil token.reload.revoked_at
        end
      end
    end
  end
end
