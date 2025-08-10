module Apex
  module Com
    class RootsController < ApplicationController
      def index
        @company_info = {
          name: "Corporate Solutions Inc.",
          founded: "2019",
          employees: "50-100",
          industry: "Technology Services"
        }

        @featured_services = [
          { name: "Enterprise Solutions", description: "Scalable business solutions" },
          { name: "Cloud Integration", description: "Seamless cloud migration" },
          { name: "Data Analytics", description: "Advanced business intelligence" }
        ]

        @latest_updates = [
          { title: "New Partnership Announced", date: 1.week.ago },
          { title: "Product Launch Q4 2024", date: 2.weeks.ago },
          { title: "Office Expansion Complete", date: 1.month.ago }
        ]
      end
    end
  end
end
