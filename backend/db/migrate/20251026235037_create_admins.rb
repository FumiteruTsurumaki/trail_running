class CreateAdmins < ActiveRecord::Migration[7.1]
  def change
    create_table :admins do |t|
      t.string :username, null: false, comment: "管理者名"
      t.string :email, null: false, comment: "メールアドレス"
      t.string :password_digest, null: false, comment: "ハッシュ化済みパスワード"
      t.integer :role, null: false, default: 0, comment: "役割 (0: 管理者, 1: オーナー)"
      t.boolean :must_change_password, null: false, default: false, comment: "パスワード変更必須フラグ"
      t.datetime :deleted_at, null: true, comment: "論理削除日時"

      t.timestamps
    end
    add_index :admins, :email, unique: true
  end
end
