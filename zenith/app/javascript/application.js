// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import { installAnalyticsConsentGate } from "analytics_consent_gate";
import "controllers";
import "theme_cookie";

installAnalyticsConsentGate();
