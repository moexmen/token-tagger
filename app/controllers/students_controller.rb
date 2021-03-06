require 'json'

class StudentsController < ApplicationController
  protect_from_forgery except: :show
  def list_students
    @students = Student.where(school_code: params[:school]).order(serial_no: :asc)

    @counts_by_class = {}
    @statuses = {}
    @students.each do |s|
      class_name = s.class_name
      status = s.status

      @counts_by_class[class_name] = {} unless @counts_by_class.key?(class_name)
      @counts_by_class[class_name][status] = 0 unless @counts_by_class[class_name].key?(status)
      @counts_by_class[class_name][status] += 1


      @statuses[status] = 0 unless @statuses.key?(status)
      @statuses[status] += 1
    end
    @class_names = @counts_by_class.keys.sort
    @token_weight = ENV['TOKEN_WEIGHT'].present? ? ENV['TOKEN_WEIGHT'].to_f : 17.85
    @bag_weight = ENV['BAG_WEIGHT'].present? ? ENV['BAG_WEIGHT'].to_f : 4.01
  end

  def taggable_students
    @students = Student.taggable.where(school_code: params[:school])
  end


  def next_student
    student = Student.taggable.where(school: params[:school])
    if params[:serial_no]
      student = student.where('serial_no >= ?', params[:serial_no])
    end

    student = student.first
    @student_json = if student.nil?
                      nil
                    else
                      {
                        id: student.id,
                        school_code: student.school_code,
                        school_name: student.school.name,
                        serial_no: student.serial_no,
                        name: student.name,
                        class_name: student.class_name,
                        level: student.level,
                        batch: student.batch
                      }
                    end
  end

  def tag
    client = Sally::Client.new(ENV['SALLY_API_ENDPOINT'], ENV['SALLY_API_KEY'])

    @student = Student.taggable.find_by(id: params[:student_id])
    return head :bad_request if @student.nil?

    @result = client.assign_token(params[:token_id], @student)

    if @result[:success] || @result[:reason] == Sally::PERSON_HAS_TOKEN || @result[:reason] == Sally::INVALID_NRIC
      @next_student = @student.next
    else
      @next_student = @student
    end

    render 'tag'

  rescue StandardError => e
    logger.error("Error tagging student_id: #{params[:student_id]}, token_id: #{params[:token_id]} | #{e.class}: #{e.message}")

    return head :internal_server_error
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
