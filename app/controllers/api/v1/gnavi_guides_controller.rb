##################################################
# ぐるなび関連のAPI郡
##################################################
class Api::V1::GnaviGuidesController < ApplicationController
  include GoogleMapHandler
  include GnaviHandler

  def restaurants
    # GoogleMapAPIから位置情報を取得
    google_map_res = location_info(address_str: params[:address_str])

    location = google_map_res.body['results'].first

    # 経度・緯度を抽出
    lat = location.dig('geometry', 'location', 'lat')
    lng = location.dig('geometry', 'location', 'lng')

    # ぐるなびAPIで位置情報にマッチするレストランの候補を出力
    gnavi_res = suggest_restaurants(latitude: lat, longitude: lng)

    render json: { status: gnavi_res.code, data: gnavi_res.body }
  end
end
