class Student < ApplicationRecord
  scope :taggable, -> { where('status = ?', :pending).order(id: :asc) }

  enum status: { pending: 'pending', assigned: 'assigned', error: 'error-quota' }
end
