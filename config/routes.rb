Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'gnavi_guides/restaurants'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    # Ver1系
    namespace :v1 do
      # GoogleMapAPI郡
      # scope :map_guides do
      #   get 'location_info', to: 'map_guides#location_info'
      # end

      # ぐるなびAPI郡
      scope :gnavi_guides do
        get 'restaurants', to: 'gnavi_guides#restaurants'
      end
    end
  end
end
