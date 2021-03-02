class SchoolsController < ApplicationController
  def list_schools
    @schools = School.all.order(name: :asc)
    @pending = Student.where(status: 'pending').group(:school_code).count
  end

  def overall
    @date = Date.strptime(params[:date], '%Y-%m-%d') unless params[:date].nil?
    @date = Date.current if @date.nil?
    @date = @date.in_time_zone('Asia/Singapore')

    @date_counts = Student.where(tagged_at: @date.beginning_of_day..@date.end_of_day).group(:school_code).count
    @schools = School.where(code: @date_counts.keys)

    @counts_by_school = {}
    counts = Student.where(school_code: @date_counts.keys).group(:school_code).group(:status).count
    counts.each do |k,v|
      @counts_by_school[k[0]] = {} unless @counts_by_school.key?(k[0])
      @counts_by_school[k[0]][k[1]] = v
    end
  end
end
