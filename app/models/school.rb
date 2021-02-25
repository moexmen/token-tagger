class School < ApplicationRecord
  has_many :students, foreign_key: 'school_code', primary_key: 'code'
end
