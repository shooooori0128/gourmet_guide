class ApplicationController < ActionController::API
  # gem 'line-bot-api'
  require 'line/bot'

  include HttpHandler

  before_action :valid_signature

  rescue_from StandardError, with: :reply_error_message

  def valid_signature
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']

    error 400 do 'Bad Request' end unless client.validate_signature(body, signature)
  end

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token  = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def reply_error_message(exception)
    error_log(exception: exception) if exception

    events = client.parse_events_from(request.body.read)

    events.each do |event|
      client.reply_message(event['replyToken'], {
                             type: 'text',
                             text: '内部エラーが発生しました！管理者に連絡してください！'
                           })
    end

    'NG'
  end

  private

  def error_log(exception:)
    logger.error("exception: #{exception&.exception}")
    logger.error("message: #{exception&.message}")
    logger.error("bactrace: #{exception&.backtrace&.join("\n")}")
  end
end
