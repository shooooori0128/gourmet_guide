##################################################
# GoogleMapAPIのラッパーモジュール
##################################################
module GoogleMapHandler
  extend ActiveSupport::Concern

  ### GoogleMapAPIの生データ取得
  # [HACK]ココらへんは仕様をよく読んでいないので、不明なエラーが発生する可能性あり
  def fetch_location_info(address_str: '')
    # valid_address(address_str: address_str)

    url = URI.parse(Constants::GCP_MAP_API_URL)
    url.query = {
      key: gcp_map_api_key,
      components: 'country:JP',
      address: address_str
    }.to_query

    # concerns/http_handler.rb
    response = get_request(url: url)

    # unless response.body.dig('status').present? || response.body.dig('status')&.first == 'OK'
    #   raise "位置情報の取得に失敗しました！ => 結果: #{response.body}"
    # end

    response.body['results'].first
  end

  ### GoogleMapAPIの生データから経度・緯度のみを返却
  def fetch_location_lat_lng(address_str: '')
    # 生データの取得
    location = fetch_location_info(address_str: address_str)

    lat = location.dig('geometry', 'location', 'lat')
    lng = location.dig('geometry', 'location', 'lng')

    [lat, lng]
  end

  ### 引数の検証
  def valid_address(address_str:)
    raise '位置情報か、現在地が入力されていないため、検索できません！' if address_str.blank?
  end

  ### APIキーの取得
  def gcp_map_api_key
    api_key = ENV.fetch('GCP_MAP_API_KEY', '')

    # raise 'GoogleMapAPIキーの取得に失敗しました！' if api_key.blank?

    api_key
  end
end
