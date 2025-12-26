class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to database: { writing: :business, reading: :business }
end
