Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'set_table', to: 'sessions#new'
  post 'set_table', to: 'sessions#set_table'

  root to: 'schools#list_schools'
  get 'overall', to: 'schools#overall'
  get 'student', to: 'students#show'
  get 'students', to: 'students#list_students'
  get 'taggable_students/:school', to: 'students#taggable_students'
  get 'students/next', to: 'students#next_student'
  post 'students/tag', to: 'students#tag'
end
