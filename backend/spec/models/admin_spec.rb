require "rails_helper"

RSpec.describe Admin, type: :model do
  describe "validations" do
    it "管理者名、メールアドレス、パスワードがあれば有効であること" do
      admin = Admin.new(
        username: "test_admin",
        email: "admin@example.com",
        password: "password123"
      )
      expect(admin).to be_valid
    end

    it "管理者名がない場合は無効であること" do
      admin = Admin.new(username: nil)
      admin.valid?
      expect(admin.errors[:username]).to include("を入力してください")
    end

    it "メールアドレスがない場合は無効であること" do
      admin = Admin.new(email: nil)
      admin.valid?
      expect(admin.errors[:email]).to include("を入力してください")
    end

    it "メールアドレスが重複している場合は無効であること" do
      Admin.create(
        username: "admin1",
        email: "admin@example.com",
        password: "password123"
      )
      admin = Admin.new(
        username: "admin2",
        email: "admin@example.com",
        password: "password123"
      )
      admin.valid?
      expect(admin.errors[:email]).to include("は既に使用されています")
    end

    it "パスワードが8文字未満の場合は無効であること" do
      admin = Admin.new(password: "1234567")
      admin.valid?
      expect(admin.errors[:password]).to include("は8文字以上で入力してください")
    end
  end

  describe "enums" do
    it "役割のデフォルト値がadmin（管理者）であること" do
      admin = Admin.new
      expect(admin.role).to eq("admin")
      expect(admin.admin?).to be true
    end

    it "役割にowner（オーナー）を設定できること" do
      admin = Admin.new(role: :owner)
      expect(admin.role).to eq("owner")
      expect(admin.owner?).to be true
    end
  end
end
