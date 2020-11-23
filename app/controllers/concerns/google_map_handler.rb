##################################################
# GoogleMapAPIのラッパーモジュール
##################################################
module GoogleMapHandler
  extend ActiveSupport::Concern

  def location_info(address_str: '')
    raise '現在地には何かを入力する必要があります。' if address_str.blank?

    url = URI.parse(Constants::GCP_MAP_API_URL)
    url.query = {
      key: ENV.fetch('GCP_MAP_API_KEY', 'unknown'),
      components: 'country:JP',
      address: address_str
    }.to_query

    # concerns/http_handler.rb
    get_request(url: url)
  end
end
