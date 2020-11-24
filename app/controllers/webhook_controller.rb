class WebhookController < ApplicationController
  require 'line/bot'  # gem 'line-bot-api'

  include GoogleMapHandler
  include GnaviHandler

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def callback
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    halt 400, { 'Content-Type' => 'text/plain' }, 'Bad Request' unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)

    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          # GoogleMapAPIから位置情報を取得
          google_map_res = location_info(address_str: event.message['text'])

          location = google_map_res.body['results'].first

          # 経度・緯度を抽出
          lat = location.dig('geometry', 'location', 'lat')
          lng = location.dig('geometry', 'location', 'lng')

          # ぐるなびAPIで位置情報にマッチするレストランの候補を出力
          gnavi_res = suggest_restaurants(latitude: lat, longitude: lng)

          first_shop = gnavi_res.body['rest']

          # message = {
          #   type: 'text',
          #   text: first_shop[0]['name']
          # }

          message = {
            type: 'template',
            altText: 'this is a carousel template',
            template: {
              type: 'carousel',
              columns: [
                {
                  thumbnailImageUrl: 'https://example.com/bot/images/item1.jpg',
                  imageBackgroundColor: '#FFFFFF',
                  title: 'this is menu',
                  text: 'description',
                  defaultAction: {
                    type: 'uri',
                    label: 'View detail',
                    uri: 'http://example.com/page/123'
                  },
                  actions: [
                    {
                      type: 'postback',
                      label: 'Buy',
                      data: 'action=buy&itemid=111'
                    },
                    {
                      type: 'postback',
                      label: 'Add to cart',
                      data: 'action=add&itemid=111'
                    },
                    {
                      type: 'uri',
                      label: 'View detail',
                      uri: 'http://example.com/page/111'
                    }
                  ]
                },
                {
                  thumbnailImageUrl: 'https://example.com/bot/images/item1.jpg',
                  imageBackgroundColor: '#FFFFFF',
                  title: 'this is menu',
                  text: 'description',
                  defaultAction: {
                    type: 'uri',
                    label: 'View detail',
                    uri: 'http://example.com/page/123'
                  },
                  actions: [
                    {
                      type: 'postback',
                      label: 'Buy',
                      data: 'action=buy&itemid=111'
                    },
                    {
                      type: 'postback',
                      label: 'Add to cart',
                      data: 'action=add&itemid=111'
                    },
                    {
                      type: 'uri',
                      label: 'View detail',
                      uri: 'http://example.com/page/111'
                    }
                  ]
                }
              ]
            }
          }

          client.reply_message(event['replyToken'], message)
        end
      end
    end

    'OK'
  end
end
