# frozen_string_literal: true

# This patch overrides the dependent: :nullify option on ContactCategory models
# which causes ActiveRecord::NotNullViolation during test cleanup/fixture loading
# because the associated foreign key columns are NOT NULL.

puts I18n.t("test.support.fix_fk_dependency.apply", default: "Applying FK Dependency Patch...")

[AppContactCategory, ComContactCategory, OrgContactCategory].each do |klass|
  klass.has_many klass.name.underscore.sub("_category", "s").to_sym,
                 foreign_key: :category_id,
                 primary_key: :id,
                 dependent: :restrict_with_error,
                 inverse_of: klass.name.underscore.to_sym
end
