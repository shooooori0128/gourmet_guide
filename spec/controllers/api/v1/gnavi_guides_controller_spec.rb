require 'rails_helper'

RSpec.describe Api::V1::GnaviGuidesController, type: :controller do
  describe 'GET #restaurants' do
    it '正常な経度・緯度を与えて、正常なレスポンスが返る' do
      get :restaurants, params: { latitude: '', longitude: '' }

      json = JSON.parse(response.body)

      # リクエスト成功を表す200が返ってきたか確認する。
      expect(json['status']).to eq(200)

      # 正しい数のデータが返されたか確認する。
      expect(json['data'].length).to be >= 1
    end

    it '経度が入力されていない場合はエラーになる' do
      get :restaurants, params: { latitude: '', longitude: '' }

      json = JSON.parse(response.body)

      # 内部エラーを表す500が返ってきたか確認する。
      expect(json['status']).to eq(500)
    end

    it '緯度が入力されていない場合はエラーになる' do
      get :restaurants, params: { latitude: '', longitude: '' }

      json = JSON.parse(response.body)

      # 内部エラーを表す500が返ってきたか確認する。
      expect(json['status']).to eq(500)
    end
  end
end
