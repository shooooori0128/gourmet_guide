##################################################
# RubyのHTTPクラスのラッパーモジュール
##################################################
module HttpHandler
  require 'net/http'

  def get_request(url:)
    request = Net::HTTP::Get.new(url.request_uri)

    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = 15
    http.read_timeout = 60

    if url.port == 443
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    response = http.start do |connection|
      connection.request(request)
    end

    response.body = JSON.parse(response.body.force_encoding('UTF-8'))

    response
  end
end
