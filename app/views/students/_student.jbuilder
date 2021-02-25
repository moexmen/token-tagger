# frozen_string_literal: true

json.call(student, :id, :school_code, :serial_no, :name, :class_name, :level, :batch)
json.school_name student.school.name
