# frozen_string_literal: true

Rails.application.routes.draw do
  root 'data_machines#index'
  post '/check_ip', to: 'data_machines#check_ip'
end
