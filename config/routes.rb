# frozen_string_literal: true

Rails.application.routes.draw do
  root 'welcome#index'

  post 'check', to: 'welcome#check'
  get 'info/:id', to: 'welcome#info', as: :info
  post 'start', to: 'welcome#start'
  post 'stop', to: 'welcome#stop'
end
