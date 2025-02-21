class SchoolClassesStudent < ApplicationRecord
  belongs_to :SchoolClasses
  belongs_to :Students
end
