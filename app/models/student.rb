class Student < ApplicationRecord
  enum status: { pending: 'pending', assigned: 'assigned', error: 'error-quota' }
end
