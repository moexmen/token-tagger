require 'json'

class StudentsController < ApplicationController
  protect_from_forgery except: :show

  def list_schools
    @schools = School.all
  end

  def list_students
    return redirect_to :action => "list_schools" if params["school"].nil? || params["school"] == ""

    @students = Student.where(school_code: params[:school])
    @school = @students.first.school
    @statuses = @students.group(:status).count
  end


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
    client = Sally::Client.new(ENV['SALLY_API_ENDPOINT'], ENV['SALLY_API_KEY'])

    @student = Student.taggable.find_by(id: params[:student_id])
    return head :bad_request if @student.nil?

    @result = client.assign_token(params[:token_id], @student.nric, @student.contact)

    if @result[:success] || @result[:reason] == Sally::PERSON_HAS_TOKEN || @result[:reason] == Sally::INVALID_NRIC
      @next_student = @student.next
    else
      @next_student = @student
    end

    render 'tag'
  end

  def show
    if params[:token_id]
      @student = Student.find_by(token_id: params[:token_id])
    end

    respond_to do |format|
      format.json
      format.html
    end
  end
end
