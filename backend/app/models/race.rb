class Race < ApplicationRecord
  # 必須項目のバリデーション
  validates :name, presence: true
  validates :date_start, presence: true
  # 大会名と開始日の組み合わせが一意であることを保証する
  validates :name, uniqueness: { scope: :date_start, message: "と開始日の組み合わせは既に存在します" }
end
