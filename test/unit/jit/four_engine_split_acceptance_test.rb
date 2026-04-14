# typed: false
# frozen_string_literal: true

require "test_helper"

# Acceptance tests for the 4-engine split.
# These tests verify the structural and behavioral expectations
# after each phase of the engine extraction.
#
# Related: plans/active/four-engine-split.md
# Issues: #667 (scaffold), #668-#671 (extractions)
class FourEngineSplitAcceptanceTest < ActiveSupport::TestCase
  # --------------------------------------------------------------------------
  # Phase 1: Scaffold and DEPLOY_MODE (#667)
  # --------------------------------------------------------------------------

  test "phase 1: four engine classes are defined" do
    assert defined?(Jit::Signature::Engine), "Jit::Signature::Engine is not defined"
    assert defined?(Jit::World::Engine),     "Jit::World::Engine is not defined"
    assert defined?(Jit::Station::Engine),   "Jit::Station::Engine is not defined"
    assert defined?(Jit::Press::Engine),     "Jit::Press::Engine is not defined"
  end

  test "phase 1: each engine is a Rails::Engine subclass" do
    assert_operator Jit::Signature::Engine, :<, Rails::Engine
    assert_operator Jit::World::Engine,     :<, Rails::Engine
    assert_operator Jit::Station::Engine,   :<, Rails::Engine
    assert_operator Jit::Press::Engine,     :<, Rails::Engine
  end

  test "phase 1: engine directories exist with expected structure" do
    %w(signature world station press).each do |name|
      engine_root = Rails.root.join("engines", name)

      assert_predicate engine_root, :directory?, "engines/#{name}/ directory does not exist"
      assert_predicate engine_root.join("lib", "jit", name, "engine.rb"), :file?,
                       "engines/#{name}/lib/jit/#{name}/engine.rb does not exist"
      assert_predicate engine_root.join("config", "routes.rb"), :file?,
                       "engines/#{name}/config/routes.rb does not exist"
    end
  end

  test "phase 1: old local engine is removed" do
    assert_not Rails.root.join("engines/local").directory?,
               "engines/local/ should be removed (superseded by 4-engine split)"
  end

  test "phase 1: deployment module supports four modes" do
    assert_respond_to Jit::Deployment, :signature?
    assert_respond_to Jit::Deployment, :world?
    assert_respond_to Jit::Deployment, :station?
    assert_respond_to Jit::Deployment, :press?
  end

  test "phase 1: deployment predicates return true for own mode and development" do
    original_mode = ENV["DEPLOY_MODE"]

    {
      "signature" => :signature?,
      "world" => :world?,
      "station" => :station?,
      "press" => :press?,
    }.each do |mode, predicate|
      ENV["DEPLOY_MODE"] = mode

      assert Jit::Deployment.public_send(predicate),
             "#{predicate} should return true for DEPLOY_MODE=#{mode}"

      ENV["DEPLOY_MODE"] = "development"

      assert Jit::Deployment.public_send(predicate),
             "#{predicate} should return true for DEPLOY_MODE=development"
    end
  ensure
    original_mode.nil? ? ENV.delete("DEPLOY_MODE") : ENV["DEPLOY_MODE"] = original_mode
  end

  test "phase 1: deployment predicates return false for other modes" do
    original_mode = ENV["DEPLOY_MODE"]

    ENV["DEPLOY_MODE"] = "signature"

    assert_not Jit::Deployment.world?,   "world? should be false for DEPLOY_MODE=signature"
    assert_not Jit::Deployment.station?, "station? should be false for DEPLOY_MODE=signature"
    assert_not Jit::Deployment.press?,   "press? should be false for DEPLOY_MODE=signature"

    ENV["DEPLOY_MODE"] = "press"

    assert_not Jit::Deployment.signature?, "signature? should be false for DEPLOY_MODE=press"
    assert_not Jit::Deployment.world?,     "world? should be false for DEPLOY_MODE=press"
    assert_not Jit::Deployment.station?,   "station? should be false for DEPLOY_MODE=press"
  ensure
    original_mode.nil? ? ENV.delete("DEPLOY_MODE") : ENV["DEPLOY_MODE"] = original_mode
  end

  test "phase 1: legacy compatibility predicates remain available" do
    original_mode = ENV["DEPLOY_MODE"]

    assert_respond_to Jit::Deployment, :global?
    assert_respond_to Jit::Deployment, :local?

    ENV["DEPLOY_MODE"] = "signature"

    assert_predicate Jit::Deployment, :global?
    assert_not Jit::Deployment.local?

    ENV["DEPLOY_MODE"] = "station"

    assert_not Jit::Deployment.global?
    assert_predicate Jit::Deployment, :local?
  ensure
    original_mode.nil? ? ENV.delete("DEPLOY_MODE") : ENV["DEPLOY_MODE"] = original_mode
  end

  # --------------------------------------------------------------------------
  # Phase 2: Extract press (#671)
  # --------------------------------------------------------------------------

  test "phase 2: docs controllers exist in press engine" do
    press_controllers = Rails.root.join("engines/press/app/controllers/docs")

    assert_predicate press_controllers, :directory?,
                     "engines/press/app/controllers/docs/ does not exist"

    %w(app com org).each do |tier|
      assert_predicate press_controllers.join(tier), :directory?,
                       "engines/press/app/controllers/docs/#{tier}/ does not exist"
    end
  end

  test "phase 2: docs controllers are not in main app" do
    main_docs = Rails.root.join("app/controllers/docs")

    assert_not main_docs.directory?,
               "app/controllers/docs/ should be moved to engines/press/"
  end

  test "phase 2: engine test helpers exist" do
    %w(signature world station press).each do |name|
      assert_predicate Rails.root.join("engines", name, "test", "test_helper.rb"), :file?,
                       "engines/#{name}/test/test_helper.rb does not exist"
    end
  end

  # --------------------------------------------------------------------------
  # Phase 3: Extract world (#669)
  # --------------------------------------------------------------------------

  test "phase 3: apex controllers exist in world engine" do
    world_controllers = Rails.root.join("engines/world/app/controllers/apex")

    assert_predicate world_controllers, :directory?,
                     "engines/world/app/controllers/apex/ does not exist"

    %w(app com org).each do |tier|
      assert_predicate world_controllers.join(tier), :directory?,
                       "engines/world/app/controllers/apex/#{tier}/ does not exist"
    end
  end

  test "phase 3: apex controllers are not in main app" do
    main_apex = Rails.root.join("app/controllers/apex")

    assert_not main_apex.directory?,
               "app/controllers/apex/ should be moved to engines/world/"
  end

  # --------------------------------------------------------------------------
  # Phase 4: Extract station (#670)
  # --------------------------------------------------------------------------

  test "phase 4: core controllers exist in station engine" do
    station_controllers = Rails.root.join("engines/station/app/controllers/core")

    assert_predicate station_controllers, :directory?,
                     "engines/station/app/controllers/core/ does not exist"

    %w(app com org).each do |tier|
      assert_predicate station_controllers.join(tier), :directory?,
                       "engines/station/app/controllers/core/#{tier}/ does not exist"
    end
  end

  test "phase 4: core controllers are not in main app" do
    main_core = Rails.root.join("app/controllers/core")

    assert_not main_core.directory?,
               "app/controllers/core/ should be moved to engines/station/"
  end

  # --------------------------------------------------------------------------
  # Phase 5: Extract signature (#668)
  # --------------------------------------------------------------------------

  test "phase 5: sign controllers exist in signature engine" do
    sig_controllers = Rails.root.join("engines/signature/app/controllers/sign")

    assert_predicate sig_controllers, :directory?,
                     "engines/signature/app/controllers/sign/ does not exist"

    %w(app com org).each do |tier|
      assert_predicate sig_controllers.join(tier), :directory?,
                       "engines/signature/app/controllers/sign/#{tier}/ does not exist"
    end
  end

  test "phase 5: sign controllers are not in main app" do
    main_sign = Rails.root.join("app/controllers/sign")

    assert_not main_sign.directory?,
               "app/controllers/sign/ should be moved to engines/signature/"
  end

  test "phase 5: sign-specific concerns moved to signature engine" do
    engine_sign_concerns = Rails.root.join(
      "engines/signature/app/controllers/concerns/sign",
    )

    assert_predicate engine_sign_concerns, :directory?,
                     "engines/signature/app/controllers/concerns/sign/ does not exist"

    main_sign_concerns = Rails.root.join("app/controllers/concerns/sign")

    assert_not main_sign_concerns.directory?,
               "app/controllers/concerns/sign/ should be moved to engines/signature/"
  end

  # --------------------------------------------------------------------------
  # Phase 6: Cleanup
  # --------------------------------------------------------------------------

  test "phase 6: shared concerns remain in main app" do
    %w(authentication authorization preference verification).each do |concern_dir|
      assert_predicate Rails.root.join("app", "controllers", "concerns", concern_dir), :directory?,
                       "Shared concern directory concerns/#{concern_dir}/ must remain in main app"
    end
  end

  test "phase 6: models remain in main app" do
    assert_predicate Rails.root.join("app/models"), :directory?,
                     "app/models/ must remain in main app (thin engine design)"

    # Verify key base record classes still exist in main app
    %w(principal_record.rb operator_record.rb token_record.rb document_record.rb).each do |model|
      assert_predicate Rails.root.join("app", "models", model), :file?,
                       "app/models/#{model} must remain in main app"
    end
  end

  test "phase 6: no stale route draw calls in main routes" do
    routes_content = Rails.root.join("config/routes.rb").read

    assert_no_match(
      /draw\s+:sign/, routes_content,
      "config/routes.rb should not contain 'draw :sign' (moved to signature engine)",
    )
    assert_no_match(
      /draw\s+:apex/, routes_content,
      "config/routes.rb should not contain 'draw :apex' (moved to world engine)",
    )
    assert_no_match(
      /draw\s+:core/, routes_content,
      "config/routes.rb should not contain 'draw :core' (moved to station engine)",
    )
    assert_no_match(
      /draw\s+:docs/, routes_content,
      "config/routes.rb should not contain 'draw :docs' (moved to press engine)",
    )
  end

  test "phase 6: route file stubs removed from main app" do
    %w(sign.rb apex.rb core.rb docs.rb).each do |route_file|
      assert_not Rails.root.join("config", "routes", route_file).file?,
                 "config/routes/#{route_file} should be removed (content moved to engine)"
    end
  end
end
