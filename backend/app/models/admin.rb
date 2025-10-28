class Admin < ApplicationRecord
	# has_secure_passwordの機能を有効にする
	# これにより、passwordとpassword_confirmationの仮想属性が追加され、password_digestカラムにハッシュ化されたパスワードが保存される
	has_secure_password

	# roleカラムをenumとして定義
	enum role: { admin: 0, owner: 1 }

	# バリデーション
	validates :username, presence: true
	validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
	# passwordは新規作成時と更新時でバリデーションを分けたい場合があるため、
	# allow_nil: true をつけて更新時に空でも通るようにしておくことが多い。
	validates :password, presence: true, length: { minimum: 8 }, allow_nil: true
end
