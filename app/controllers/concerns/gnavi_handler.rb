require 'net/http'

##################################################
# ぐるなびAPIのラッパーモジュール
##################################################
module GnaviHandler
  extend ActiveSupport::Concern

  ### 経度・緯度に一致する付近のレストランを検索（10件）
  # API仕様
  # https://api.gnavi.co.jp/api/manual/restsearch/
  def fetch_restaurants(lat: 0, lng: 0)
    # valid_lat_lng(lat: lat, lng: lng)

    url = URI.parse(Constants::GNAVI_RESTRANT_API_URL)
    url.query = {
      keyid: gnavi_api_key,
      latitude: lat.to_f,
      longitude: lng.to_f,
      range: 1
    }.to_query

    # concerns/http_handler.rb
    response = get_request(url: url)

    # raise "レストランの検索に失敗しました => 結果: #{response.body}" if response.body.dig('error').present?

    response.body['rest']
  end

  ### 引数の検証
  def valid_lat_lng(lat:, lng:)
    raise '緯度が入力されていないため、検索できませんでした！' if lat.zero? || lat.blank?

    raise '経度が入力されていないため、検索できませんでした！' if lng.zero? || lng.blank?
  end

  ### APIキーの取得
  def gnavi_api_key
    api_key = ENV.fetch('GNAVI_API_KEY', '')

    # raise 'ぐるなびAPIキーの取得に失敗しました！' if api_key.blank?

    api_key
  end
end
