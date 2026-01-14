# frozen_string_literal: true

Rails.logger.debug "Seeding Preference Statuses..."

%w(app org com).each do |prefix|
  status_class = "#{prefix.capitalize}PreferenceStatus".constantize

  # Ensure NEYO
  unless status_class.exists?(id: "NEYO")
    position = (status_class.maximum(:position) || 0) + 1
    status_class.create!(id: "NEYO", position: position)
    Rails.logger.debug { "Created #{prefix.capitalize}PreferenceStatus: NEYO" }
  end

  # Ensure DELETED
  unless status_class.exists?(id: "DELETED")
    position = (status_class.maximum(:position) || 0) + 1
    status_class.create!(id: "DELETED", position: position)
    Rails.logger.debug { "Created #{prefix.capitalize}PreferenceStatus: DELETED" }
  end
end

Rails.logger.debug "Seeding complete."
