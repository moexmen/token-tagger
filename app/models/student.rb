class Student < ApplicationRecord
  scope :taggable, -> { where('status = ?', :pending).order(serial_no: :asc) }

  enum status: { pending: 'pending', assigned: 'assigned', error_quota: 'error-quota', error_nric: 'error-nric' }

  belongs_to :school, primary_key: 'code', foreign_key: 'school_code'

  def class_name
    super.upcase.strip unless super.nil?
  end

  def next
    next_student = Student.taggable.where.not(id: id).where(school_code: school_code).where('serial_no >= ?', serial_no)
    
    next_student.first
  end
end
