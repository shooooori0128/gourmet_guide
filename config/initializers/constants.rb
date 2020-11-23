##################################################
# 本アプリケーションの定数はコチラにまとめてください
##################################################
module Constants
  # ぐるなびレストラン検索API
  GNAVI_RESTRANT_API_URL = 'https://api.gnavi.co.jp/RestSearchAPI/v3'.freeze

  # GoogleMapAPI - 住所テキストから経度緯度の算出で利用
  GCP_MAP_API_URL = 'https://maps.googleapis.com/maps/api/geocode/json'.freeze
end
