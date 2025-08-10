module Apex
  module Org
    class RootsController < ApplicationController
      def index
        @admin_dashboard = {
          total_users: 1247,
          active_sessions: 89,
          system_alerts: 3,
          pending_approvals: 12
        }
        
        @system_metrics = {
          cpu_usage: "23%",
          memory_usage: "67%",
          disk_usage: "45%",
          network_io: "Normal"
        }
        
        @recent_activities = [
          { action: "User login", user: "admin@example.com", timestamp: 5.minutes.ago },
          { action: "Settings updated", user: "staff@example.com", timestamp: 15.minutes.ago },
          { action: "System backup completed", user: "system", timestamp: 1.hour.ago },
          { action: "New user registered", user: "newuser@example.com", timestamp: 2.hours.ago }
        ]
        
        @quick_actions = [
          { name: "User Management", path: "/admin/users", icon: "users" },
          { name: "System Settings", path: "/admin/settings", icon: "settings" },
          { name: "Security Logs", path: "/admin/logs", icon: "security" },
          { name: "Backup Management", path: "/admin/backup", icon: "backup" }
        ]
      end
    end
  end
end
