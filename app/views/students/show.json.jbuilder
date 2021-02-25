json.student do
  if @student.nil?
    json.nil!
  else
    json.partial! 'students/student', student: @student
  end
end
