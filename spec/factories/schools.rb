# frozen_string_literal: true

FactoryBot.define do
  factory :school do
    sequence(:code) { |n| format('%04d', n) }
    sequence(:name) { |n| "School #{n}" }
    cluster { 'West 1' }
  end
end
