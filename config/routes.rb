Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'callback' => 'webhook#callback'
    end
  end
end
