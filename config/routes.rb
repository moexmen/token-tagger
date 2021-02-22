Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'students#list_schools'
  get 'students', to: 'students#list_students'
  get 'students/next', to: 'students#next_student'
end
