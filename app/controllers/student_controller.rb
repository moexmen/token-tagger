require 'json'

class StudentController < ApplicationController
  def next_student
    @student = Student.taggable
    if params[:batch]
      @student = @student.where(batch: params[:batch])
    elsif params[:school]
      @student = @student.where(school: params[:school])
      if params[:serial_no]
        @student = @student.where('serial_no >= ?', params[:serial_no])
      end
    end
    @student = @student.first
  end

  def tag
    client = Sally::Client.new

    student = Student.taggable.find_by(id: params[:student_id])
    return head :bad_request if student.nil?

    res = client.assign_token(params[:token_id], student.nric, student.contact)
    if res[:success]
      student.update({ token_id: params[:token_id], status: Student.statuses[:assigned]})
    elsif res[:reason] == PERSON_HAS_TOKEN
      student.update({ status: Student.statuses[:error]})
    end

    if res[:success] || res[:reason] == PERSON_HAS_TOKEN
      next_student = student.next
    else
      next_student = student
    end

    render json: {
      success: res[:success],
      reason: res[:reason],
      student: {
        id: next_student.id,
        school_code: next_student.school_code,
        name: next_student.name,
        class_name: next_student.class_name,
        level: next_student.level,
        batch: next_student.batch
      }
    }
  end
end
