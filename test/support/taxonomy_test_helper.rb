# frozen_string_literal: true

require "securerandom"

module TaxonomyTestHelper
  ROOT_SENTINEL = "NEYO"

  def ensure_root_sentinel!(klass)
    return if klass.exists?(id: ROOT_SENTINEL)

    now = Time.current
    # rubocop:disable Rails/SkipsModelValidations
    klass.insert_all!(
      [ {
        id: ROOT_SENTINEL,
        parent_id: ROOT_SENTINEL,
        created_at: now,
        updated_at: now
      } ],
    )
    # rubocop:enable Rails/SkipsModelValidations
  end

  def build_taxonomy_tree_for(klass)
    ensure_root_sentinel!(klass)
    token = SecureRandom.hex(4).upcase

    root = klass.create!(id: "ROOT_#{token}", parent_id: ROOT_SENTINEL)
    a = klass.create!(id: "A_#{token}", parent: root)
    b = klass.create!(id: "B_#{token}", parent: root)
    c = klass.create!(id: "C_#{token}", parent: root)
    c1 = klass.create!(id: "C1_#{token}", parent: c)

    { root: root, a: a, b: b, c: c, c1: c1 }
  end
end
