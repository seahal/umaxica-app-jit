# typed: false
# frozen_string_literal: true

require "test_helper"

class PreferenceGlobalParamContextTest < ActionDispatch::IntegrationTest
  setup do
    https!
  end

  DOMAINS = [
    { name: "sign_app", host: "sign.app.localhost", preference_url_method: :sign_app_preference_url },
    { name: "sign_org", host: "sign.org.localhost", preference_url_method: :sign_org_preference_url },
    { name: "sign_com", host: "sign.com.localhost", preference_url_method: :sign_com_preference_url },
  ].freeze

  # =============================================================================
  # ri parameter tests - ri is always required
  # =============================================================================

  DOMAINS.each do |domain|
    test "#{domain[:name]} redirects to add ri param when missing" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method)

      assert_response :redirect
      follow_redirect!

      # After redirect, ri should be present in URL
      assert_match(/ri=jp/, request.url)
    end

    test "#{domain[:name]} does not redirect when ri param is present" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "us")

      assert_response :success
      assert_match(/ri=us/, request.url)
    end

    test "#{domain[:name]} ri param is always included in identity.default_url_options" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "us", lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      # Check that links generated with url helpers have ri parameter
      # Look for specific navigation links that use url helpers
      links = css_select("a[href*='/preference']")
      links.each do |link|
        href = link["href"]

        assert_match(/ri=/, href, "Preference link should include ri parameter: #{href}")
      end
    end
  end

  # =============================================================================
  # Optional params tests - lx, ct, tz are only added if present in request
  # =============================================================================

  DOMAINS.each do |domain|
    test "#{domain[:name]} lx param is preserved in navigation links when present in request" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "jp", lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      # Check preference links (which use url helpers)
      links = css_select("a[href*='/preference'][href*='lx=en']")

      assert_predicate links, :any?,
                       "Preference links should preserve lx=en parameter when it was in the request"
    end

    test "#{domain[:name]} lx param is NOT added to navigation links when NOT in request" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "jp")

      assert_response :success

      # Check preference links - they should NOT have lx parameter
      links = css_select("a[href*='/preference']")
      links.each do |link|
        href = link["href"]

        assert_no_match(/lx=/, href, "Preference link should NOT include lx parameter: #{href}")
      end
    end

    test "#{domain[:name]} ct param is preserved in navigation links when present in request" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "jp", lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      links = css_select("a[href*='/preference'][href*='ct=dr']")

      assert_predicate links, :any?,
                       "Preference links should preserve ct=dr parameter when it was in the request"
    end

    test "#{domain[:name]} ct param is NOT added to navigation links when NOT in request" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "jp")

      assert_response :success

      links = css_select("a[href*='/preference']")
      links.each do |link|
        href = link["href"]

        assert_no_match(/ct=/, href, "Preference link should NOT include ct parameter: #{href}")
      end
    end

    test "#{domain[:name]} tz param is preserved in navigation links when present in request" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "jp", lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      links = css_select("a[href*='/preference'][href*='tz=utc']")

      assert_predicate links, :any?,
                       "Preference links should preserve tz=utc parameter when it was in the request"
    end

    test "#{domain[:name]} tz param is NOT added to navigation links when NOT in request" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "jp")

      assert_response :success

      links = css_select("a[href*='/preference']")
      links.each do |link|
        href = link["href"]

        assert_no_match(/tz=/, href, "Preference link should NOT include tz parameter: #{href}")
      end
    end

    test "#{domain[:name]} multiple optional params are preserved together in navigation links" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method, ri: "us", lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      # Check that preference links preserve all params
      links = css_select("a[href*='/preference']")

      assert_predicate links, :any?, "Should have preference links"

      # At least some links should have all the params
      links_with_all_params =
        links.select do |link|
          href = link["href"]
          href.include?("lx=en") && href.include?("ct=dr") && href.include?("tz=utc")
        end

      assert_predicate links_with_all_params, :any?,
                       "Some preference links should have all optional params preserved"
    end
  end

  # =============================================================================
  # Redirect behavior tests
  # =============================================================================

  DOMAINS.each do |domain|
    test "#{domain[:name]} redirect to add ri preserves existing query params" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      # Access without ri but with other params
      get public_send(url_method, foo: "bar")

      assert_response :redirect
      location = response.headers["Location"]

      # Should have ri added
      assert_match(/ri=jp/, location)
      # Should preserve other params
      assert_match(/foo=bar/, location)
    end

    test "#{domain[:name]} redirect to add ri does NOT add lx automatically" do
      host!(domain[:host])

      url_method = domain[:preference_url_method] || domain[:root_url_method]
      get public_send(url_method)

      assert_response :redirect
      location = response.headers["Location"]

      # Should have ri added
      assert_match(/ri=jp/, location)
      # Should NOT have lx added automatically
      assert_no_match(/lx=/, location)
    end
  end

  # =============================================================================
  # Preference::Regional tests - ri is NOT allowed, lx/ct/tz are preserved
  # These controllers use Preference::Regional instead of Preference::Global
  # =============================================================================

  REGIONAL_DOMAINS = [
    { name: "base_app", host: "base.app.localhost", root_url_method: :base_app_root_url },
    { name: "base_org", host: "base.org.localhost", root_url_method: :base_org_root_url },
    { name: "base_com", host: "base.com.localhost", root_url_method: :base_com_root_url },
  ].freeze

  REGIONAL_DOMAINS.each do |domain|
    test "#{domain[:name]} regional does NOT redirect when ri is absent" do
      host!(domain[:host])

      get public_send(domain[:root_url_method])

      # Should NOT redirect - ri is not required for Regional
      assert_response :success
    end

    test "#{domain[:name]} regional redirects to REMOVE ri param when present (301)" do
      host!(domain[:host])

      get public_send(domain[:root_url_method], ri: "jp")

      # Should redirect with 301 to remove ri
      assert_response :moved_permanently
      location = response.headers["Location"]

      # ri should be removed
      assert_no_match(/ri=/, location)
    end

    test "#{domain[:name]} regional redirect to remove ri preserves other params" do
      host!(domain[:host])

      get public_send(domain[:root_url_method], ri: "jp", lx: "en", ct: "dr", tz: "utc", foo: "bar")

      assert_response :moved_permanently
      location = response.headers["Location"]

      # ri should be removed
      assert_no_match(/ri=/, location)
      # Other params should be preserved
      assert_match(/lx=en/, location)
      assert_match(/ct=dr/, location)
      assert_match(/tz=utc/, location)
      assert_match(/foo=bar/, location)
    end

    test "#{domain[:name]} regional links do NOT include ri param" do
      host!(domain[:host])

      get public_send(domain[:root_url_method])

      assert_response :success

      # Check that internal links do NOT have ri parameter
      links = internal_links_for(domain[:host])
      links.each do |link|
        href = link["href"]
        next if href.start_with?("#")

        assert_no_match(/ri=/, href, "Regional link should NOT include ri parameter: #{href}")
      end
    end

    test "#{domain[:name]} regional preserves lx param in links when present" do
      host!(domain[:host])

      get public_send(domain[:root_url_method], lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      # Check that internal links preserve lx
      links = internal_links_for(domain[:host]).select { |link| link["href"].include?("lx=en") }

      assert_predicate links, :any?, "Links should preserve lx=en parameter"
    end

    test "#{domain[:name]} regional preserves ct param in links when present" do
      host!(domain[:host])

      get public_send(domain[:root_url_method], lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      links = internal_links_for(domain[:host]).select { |link| link["href"].include?("ct=dr") }

      assert_predicate links, :any?, "Links should preserve ct=dr parameter"
    end

    test "#{domain[:name]} regional preserves tz param in links when present" do
      host!(domain[:host])

      get public_send(domain[:root_url_method], lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      links = internal_links_for(domain[:host]).select { |link| link["href"].include?("tz=utc") }

      assert_predicate links, :any?, "Links should preserve tz=utc parameter"
    end

    test "#{domain[:name]} regional preserves all optional params together" do
      host!(domain[:host])

      get public_send(domain[:root_url_method], lx: "en", ct: "dr", tz: "utc")

      assert_response :success

      # Check that links have all three params
      links = internal_links_for(domain[:host])
      links_with_all =
        links.select do |link|
          href = link["href"]
          href.include?("lx=en") && href.include?("ct=dr") && href.include?("tz=utc")
        end

      assert_predicate links_with_all, :any?, "Some links should have all optional params preserved"
    end

    test "#{domain[:name]} regional does NOT add optional params when not in request" do
      host!(domain[:host])

      get public_send(domain[:root_url_method])

      assert_response :success

      # Check internal links - they should NOT have lx, ct, tz
      links = internal_links_for(domain[:host])
      links.each do |link|
        href = link["href"]
        next if href.start_with?("#")

        assert_no_match(/lx=/, href, "Link should NOT include lx when not in request: #{href}")
        assert_no_match(/ct=/, href, "Link should NOT include ct when not in request: #{href}")
        assert_no_match(/tz=/, href, "Link should NOT include tz when not in request: #{href}")
      end
    end

    test "#{domain[:name]} regional ignores unknown params in identity.default_url_options" do
      host!(domain[:host])

      # efg=abc should NOT be preserved in links (not in OPTIONAL_PARAM_KEYS)
      get public_send(domain[:root_url_method], lx: "en", ct: "dr", tz: "utc", efg: "abc")

      assert_response :success

      # lx should be in links, but efg should NOT
      links = internal_links_for(domain[:host]).select { |link| link["href"].include?("lx=en") }

      assert_predicate links, :any?, "Links should preserve lx=en"

      links.each do |link|
        href = link["href"]

        assert_no_match(/efg=/, href, "Link should NOT include efg param: #{href}")
      end
    end
  end

  private

  def internal_links_for(host)
    allowed_hosts = [
      host,
      ENV["IDENTITY_SIGN_APP_URL"],
      ENV["IDENTITY_SIGN_ORG_URL"],
      ENV["EDGE_SERVICE_URL"],
      ENV["EDGE_STAFF_URL"],
    ].compact

    css_select("a[href]").select do |link|
      href = link["href"]
      next false if href.blank? || href.start_with?("#")

      if href.start_with?("/")
        true
      else
        uri = URI.parse(href) rescue nil
        uri&.host && allowed_hosts.include?(uri.host)
      end
    end
  end
end
