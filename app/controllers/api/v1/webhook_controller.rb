##################################################
# LINEBotのコールバック用コントローラー
##################################################
class Api::V1::WebhookController < ApplicationController
  # GoogleMapAPI
  include GoogleMapHandler
  # ぐるなびAPI
  include GnaviHandler

  def callback
    events = client.parse_events_from(request.body.read)

    events.each do |event|
      message = create_massage(line_event: event)

      client.reply_message(event['replyToken'], message)
    end

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
      shop_image_url = item.dig('image_url', 'shop_image1')

      # 店舗イメージ画像に空文字を渡すと、BOTが何も返さなくなるので、適当なURLを返却する
      shop_image_url = 'https://example.com/bot/images/item1.jpg' if shop_image_url.blank?

      {
        thumbnailImageUrl: shop_image_url,
        imageBackgroundColor: '#FFFFFF',
        title: item.dig('name') || '店舗名不明',
        text: item.dig('address') || '住所不明',
        defaultAction: {
          type: 'uri',
          label: '店舗詳細',
          uri: item.dig('url_mobile') || ''
        },
        actions: [
          {
            type: 'uri',
            label: '店舗詳細',
            uri: item.dig('url_mobile') || ''
          }
        ]
      }
    end

    {
      type: 'template',
      altText: '付近の飲食店検索結果です',
      template: {
        type: 'carousel',
        columns: contents
      }
    }
  end
end
