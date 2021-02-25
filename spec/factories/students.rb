# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    school

    sequence(:name) { |n| "Student #{n}" }
    class_name { 'P1-A' }
    level { 'P1' }
    contact { '91234567' }
    sequence(:serial_no) { |n| format('%04d', n) }
    sequence(:nric) { |n| format('S1234%03dA', n) }
  end
end
