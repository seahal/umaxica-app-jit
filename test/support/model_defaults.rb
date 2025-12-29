# frozen_string_literal: true

# This file monkey-patches validation defaults for tests to avoid manually updating every test file.
# It sets required foreign keys (category_id, status_id) to "NEYO" / "ACTIVE" if they are blank.

Rails.application.reloader.to_prepare do
  if defined?(ComContact)
    ComContact.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.category_id = "NEYO" if category_id.blank?
        self.status_id = "NEYO" if status_id.blank?
      end
    end
  end

  if defined?(AppContact)
    AppContact.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.category_id = "NEYO" if category_id.blank?
        self.status_id = "NEYO" if status_id.blank?
      end
    end
  end

  if defined?(OrgContact)
    OrgContact.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.category_id = "NEYO" if category_id.blank?
        self.status_id = "NEYO" if status_id.blank?
      end
    end
  end

  if defined?(StaffToken)
    StaffToken.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.staff_token_status_id = "ACTIVE" if staff_token_status_id.blank?
      end
    end
  end

  if defined?(UserToken)
    UserToken.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.user_token_status_id = "ACTIVE" if user_token_status_id.blank?
      end
    end
  end

  # Fix for Timeline failures "status_id NEYO not present" -> Seed handled this, but validation might need it?
  # Timelines usually have status_id.
  if defined?(OrgTimeline)
    OrgTimeline.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.status_id = "NEYO" if status_id.blank?
      end
    end
  end

  if defined?(AppTimeline)
    AppTimeline.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.status_id = "NEYO" if status_id.blank?
      end
    end
  end

  if defined?(ComTimeline)
    ComTimeline.class_eval do
      before_validation :set_test_defaults, on: :create
      def set_test_defaults
        self.status_id = "NEYO" if status_id.blank?
      end
    end
  end
end
