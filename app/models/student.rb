class Student < ApplicationRecord
  scope :taggable, -> { where('status = ?', :pending).order(serial_no: :asc) }

  enum status: { pending: 'pending', assigned: 'assigned', error: 'error-quota' }

  has_one :school, foreign_key: 'code', primary_key: 'school_code'

  def next
    next_student = Student.taggable.where.not(id: id)
    next_student = next_student.where(school_code: school_code).where('serial_no >= ?', serial_no)
    
    next_student.first
  end
end
