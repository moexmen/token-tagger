class Student < ApplicationRecord
  scope :taggable, -> { where('status = ?', :pending).order(serial_no: :asc) }

  enum status: { pending: 'pending', assigned: 'assigned', error: 'error-quota' }

  def next
    next_student = Student.taggable.where.not(id: id)
    if batch.empty?
      next_student = next_student.where(school_code: school_code)
    else
      next_student = next_student.where(batch: batch)
    end
    next_student.first
  end
end
