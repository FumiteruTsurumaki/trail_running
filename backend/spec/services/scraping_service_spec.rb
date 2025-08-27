require "rails_helper"

RSpec.describe ScrapingService, type: :service do
  describe ".scrape_trailrunner_jp_races" do
    let!(:dummy_html) { File.read(Rails.root.join("spec/fixtures/files/trailrunner_jp_taikai.html")) }
    let!(:success_response) { instance_double(HTTParty::Response, code: 200, body: dummy_html) }
    let!(:failure_response) { instance_double(HTTParty::Response, code: 404) }

    before do
      # 実際のHTTPリクエストを送らないようにスタブ化
      allow(HTTParty).to receive(:get).and_return(success_response)
      
      # 既存のレースデータを準備
      Race.create!(
        name: "既存のレース",
        date_start: Date.new(Date.today.year, 8, 10),
        location: "古い場所", # 更新されることを確認するためのデータ
        distance: "古い距離"
      )
    end

    context "スクレイピングが成功した場合" do
      it "新しいレースをデータベースに作成する" do
        # 「新しいレース」が1件作成されることを期待
        expect {
          described_class.scrape_trailrunner_jp_races
        }.to change(Race, :count).by(1)

        new_race = Race.find_by(name: "新しいレース")
        expect(new_race).to be_present
        expect(new_race.date_start).to eq(Date.new(Date.today.year, 8, 1))
        expect(new_race.location).to eq("長野")
        expect(new_race.distance).to eq("100km")
        expect(new_race.official_url).to eq("https://example.com/new_race")
      end

      it "既存のレース情報を更新する" do
        existing_race = Race.find_by(name: "既存のレース")

        # 既存のレースが更新され(updated_atが変更)、新しいレースが1件追加される(countが1増える)ことを確認
        expect {
          described_class.scrape_trailrunner_jp_races
        }.to change { existing_race.reload.updated_at } # updated_atの変更をチェック
         .and change(Race, :count).by(1) # 「新しいレース」が追加されるため、カウントは1増える

        expect(existing_race.reload.location).to eq("山梨") # "古い場所" から更新されている
        expect(existing_race.reload.distance).to eq("50km") # "古い距離" から更新されている
        expect(existing_race.reload.date_end).to eq(Date.new(Date.today.year, 8, 11))
      end

      it "レース名がない場合はレコードを作成しない" do
        # レース名がない行は無視されることを確認する
        expect {
          described_class.scrape_trailrunner_jp_races
        }.to change(Race, :count).by(1) # 「新しいレース」の分だけ増える

        expect(Race.find_by(location: "不明")).to be_nil
      end
    end

    context "Webサイトへのアクセスに失敗した場合" do
      before do
        # 失敗するレスポンスを返すようにスタブを上書き
        allow(HTTParty).to receive(:get).and_return(failure_response)
      end

      it "エラーメッセージを記録し、データベースは変更されない" do
        # DBに変化がないことを確認
        expect {
          described_class.scrape_trailrunner_jp_races
        }.not_to change(Race, :count)

        # エラーメッセージが出力されることを確認
        expect { described_class.scrape_trailrunner_jp_races }.to output(/Webサイトへのアクセスに失敗しました/).to_stdout
      end
    end
  end
end