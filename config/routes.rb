Rails.application.routes.draw do
  # LINE Bot
  post 'callback' => 'webhook#callback'

  namespace :api do
    namespace :v1 do
      get 'gnavi_guides/restaurants'
    end
  end
end
