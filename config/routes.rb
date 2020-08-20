Rails.application.routes.draw do
  resources :resumes
  get '/home' => 'home#show'
  get 'download' => 'resumes#download', format: 'docx'
  get 'pdf' => 'resumes#pdf', format: 'pdf'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
