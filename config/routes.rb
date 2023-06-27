Rails.application.routes.draw do
  root 'welcome#index'

  post 'check', to: 'welcome#check'
end
