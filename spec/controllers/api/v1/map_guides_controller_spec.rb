require 'rails_helper'

RSpec.describe Api::V1::MapGuideController, type: :controller do
  describe "GET #location_info" do
    it '正常な住所を与えて、正常なレスポンスが返る' do
      get :location_info, params: { address_str: '東京都江東区白河2-1-30' }

      json = JSON.parse(response.body)

      # リクエスト成功を表す200が返ってきたか確認する。
      expect(json['status']).to eq(200)

      # 正しい数のデータが返されたか確認する。
      expect(json['data'].length).to be >= 1
    end

    it '住所が入力されていない場合はエラーになる' do
      get :location_info, params: { address_str: '' }

      json = JSON.parse(response.body)

      # 内部エラーを表す500が返ってきたか確認する。
      expect(json['status']).to eq(500)
    end
  end
end
