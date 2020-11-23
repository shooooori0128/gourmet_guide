require 'net/http'

##################################################
# ぐるなびAPIのラッパーモジュール
##################################################
module GnaviHandler
  extend ActiveSupport::Concern

  def suggest_restaurants(latitude: 0, longitude: 0)
    raise '緯度が未入力です' if latitude.zero? || latitude.blank?

    raise '経度が未入力です' if longitude.zero? || longitude.blank?

    url = URI.parse(Constants::GNAVI_RESTRANT_API_URL)
    url.query = {
      keyid: ENV.fetch('GNAVI_API_KEY', 'unknown'),
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      range: 1
    }.to_query

    # concerns/http_handler.rb
    get_request(url: url)
  end
end
