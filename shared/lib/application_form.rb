# typed: false
# frozen_string_literal: true

class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks

  # Form objects are not saved directly to the database.
  # Therefore, this method returns false by default.
  def persisted?
    false
  end
end
