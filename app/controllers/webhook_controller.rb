##################################################
# LINEBotのコールバック用コントローラー
##################################################
class WebhookController < ApplicationController
  # gem 'line-bot-api'
  require 'line/bot'

  # GoogleMapAPI
  include GoogleMapHandler
  # ぐるなびAPI
  include GnaviHandler

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token  = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    halt 400, { 'Content-Type' => 'text/plain' }, 'Bad Request' unless client.validate_signature(body, signature)

    event = client.parse_events_from(body).first

    message = create_massage(line_event: event)

    logger.info(message)

    client.reply_message(event['replyToken'], message)

    'OK'
  end

  protected

  ### イベント種類に応じたメッセージの作成
  # [HACK]ココらへんは仕様をよく読んでいないので、不明なエラーが発生する可能性あり
  def create_massage(line_event: event)
    ### messageのevent種類の定義については下記参照
    # https://github.com/line/line-bot-sdk-ruby/blob/master/lib/line/bot/event/message.rb
    restaurants = case line_event
                  when Line::Bot::Event::Message
                    case line_event.type
                    when Line::Bot::Event::MessageType::Text
                      # GoogleMapAPIから経度・緯度を取得
                      lat, lng = fetch_location_lat_lng(address_str: line_event.message['text'])

                      # ぐるなびAPIで位置情報にマッチするレストランの候補を出力
                      fetch_restaurants(lat: lat, lng: lng)
                    when Line::Bot::Event::MessageType::Location
                      # ぐるなびAPIで位置情報にマッチするレストランの候補を出力
                      fetch_restaurants(lat: line_event.message['latitude'], lng: line_event.message['longitude'])
                    end
                  end

    # eventTypeが文字列か、位置情報以外は処理しない
    if restaurants.blank?
      return {
        type: 'text',
        text: '位置情報、もしくは現在地の住所が入力されていないため、検索できません。入力内容をご確認ください。'
      }
    end

    # カルーセルフォーマットで検索結果を返す
    # https://developers.line.biz/ja/docs/messaging-api/message-types/#carousel-template
    carousel_format(items: restaurants)
  end

  ### カルーセルタイプのメッセージフォーマット
  # https://developers.line.biz/ja/reference/messaging-api/#carousel
  def carousel_format(items: [])
    contents = items.map do |item|
      {
        thumbnailImageUrl: item.dig('image_url', 'shop_image1') || 'https://example.com/bot/images/item1.jpg',
        imageBackgroundColor: '#FFFFFF',
        title: item.dig('name') || 'this is menu',
        text: item.dig('address') || 'description',
        defaultAction: {
          type: 'uri',
          label: 'Detail',
          uri: item.dig('url_mobile') || 'http://example.com/page/123'
        },
        actions: [
          {
            type: 'postback',
            label: 'Buy',
            data: 'action=buy&itemid=111'
          }
        ]
      }
    end

    {
      type: 'template',
      altText: 'this is a carousel template',
      template: {
        type: 'carousel',
        columns: contents
      }
    }.to_json
  end
end
