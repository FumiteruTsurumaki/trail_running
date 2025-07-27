module Api
  module V1
    class RacesController < ApplicationController
      # CORS対応（開発環境用）
      before_action :set_access_control_headers

      def index
        # 承認済み (status: 1) のレースのみを取得し、日付が新しい順に並べ替える
        @races = Race.where(status: 1).order(date: :desc)
        render json: @races
      end

      def show
        @race = Race.find(params[:id])
        render json: @race
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Race not found' }, status: :not_found
      end

      private

      # CORSヘッダーを設定するメソッド (開発環境では必要)
      def set_access_control_headers
        headers['Access-Control-Allow-Origin'] = '*' # すべてのオリジンからのアクセスを許可
        headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization'
      end
    end
  end
end
