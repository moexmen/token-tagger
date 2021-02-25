json.result do
  json.success @result[:success]
  json.reason @result[:reason]
  json.student do
    json.partial! 'students/student', student: @student
  end
end

json.next_student do
  if @next_student.nil?
    json.nil!
  else
    json.partial! 'students/student', student: @next_student
  end
end

json.csrf_token form_authenticity_token
