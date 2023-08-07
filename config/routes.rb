# frozen_string_literal: true

Rails.application.routes.draw do
  root 'machine#index'

  post 'check', to: 'machine#check'
  get 'info/:sn', to: 'machine#info', as: :info
  post 'change_state', to: 'machine#change_state'
end
