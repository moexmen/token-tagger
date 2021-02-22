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

    render 'students/next_student'
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
      result: {
        success: res[:success],
        reason: res[:reason],
        student: {
          id: student.id,
          school_code: student.school_code,
          school_name: student.school.name,
          serial_no: student.serial_no,
          name: student.name,
          class_name: student.class_name,
          level: student.level,
          batch: student.batch
        },
      },
      next_student: {
        id: next_student.id,
        school_code: next_student.school_code,
        school_name: next_student.school.name,
        serial_no: next_student.serial_no,
        name: next_student.name,
        class_name: next_student.class_name,
        level: next_student.level,
        batch: next_student.batch
      }
    }
  end
end
