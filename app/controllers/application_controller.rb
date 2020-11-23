class ApplicationController < ActionController::API
  include HttpHandler

  rescue_from StandardError, with: :render_500

  def render_500(exception)
    error_log(exception: exception) if exception

    render json: { status: 500, data: '内部エラーが発生しました！パラメータを確認してください！' }
  end

  private

  def error_log(exception:)
    logger.error("exception: #{exception&.exception}")
    logger.error("message: #{exception&.message}")
    logger.error("bactrace: #{exception&.backtrace&.join("\n")}")
  end
end
