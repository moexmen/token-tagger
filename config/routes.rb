Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'students#list_schools'
  get 'student', to: 'students#show'
  get 'students', to: 'students#list_students'
  get 'taggable_students/:school', to: 'students#taggable_students'
  get 'students/next', to: 'students#next_student'
  post 'students/tag', to: 'students#tag'
end
