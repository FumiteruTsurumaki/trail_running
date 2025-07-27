module Api
  module V1
    class KnowledgeController < ApplicationController
      # CORS対応（開発環境用）
      before_action :set_access_control_headers

      def index
        @knowledge_articles = Knowledge.all
        render json: @knowledge_articles
      end

      def show
        @knowledge_article = Knowledge.find(params[:id])
        render json: @knowledge_article
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Knowledge article not found' }, status: :not_found
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
