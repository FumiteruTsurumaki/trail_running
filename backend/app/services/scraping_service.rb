require "httparty"
require "nokogiri"
require "date"

class ScrapingService
  TRAILRUNNER_JP_TAIKAI_URL = "https://trailrunner.jp/taikai.html"
  
  def self.scrape_trailrunner_jp_races
    puts "TrailRunner.JPからトレイルレース情報のスクレイピングを開始します..."
    
    response = HTTParty.get(TRAILRUNNER_JP_TAIKAI_URL, headers: { "User-Agent" => "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" })

    unless response.code == 200
      puts "Webサイトへのアクセスに失敗しました。ステータスコード: #{response.code}"
      return
    end

    doc = Nokogiri::HTML(response.body)
    
    # TrailRunner.JPの大会リストのセレクタを探します。
    # ページの構造により、変更が必要な場合があります。
    # 最新のHTML構造に合わせて、開発者ツールで正確なセレクタを確認してください。
    # 例: <table>要素内の<tr>を大会情報として取得
    # あるいは、特定のクラスを持つdiv要素のリストなど
    
    # 2025年7月時点のTrailRunner.JPのHTML構造を元にしたセレクタの例:
    # 大会情報がtbody > tr の中に格納されていると仮定
    races_elements = doc.css("table tbody tr") 

    puts "取得した大会要素の数: #{races_elements.count}"

    races_data = []
    races_elements.each do |race_element|
      # 各情報の抽出（セレクタはTrailRunner.JPの現在のHTML構造に合わせて調整してください）
      # 2025年7月時点の構造を元にした抽出例
      cells = race_element.css("td")
      next if cells.length < 2 # 必要なセルがない行はスキップ

      td1_text = cells[0]&.at_css("span")&.text&.strip
      td2_element = cells[1]
      td2_text = td2_element&.text&.strip

      next unless td1_text && td2_text # 日付や大会情報がない行はスキップ

      # --- 開催日 ---
      current_year = Date.today.year
      date_parts = td1_text.split('_')
      race_date_start = parse_date_from_string(date_parts[0], current_year)
      race_date_end = parse_date_from_string(date_parts[1], current_year) if date_parts.length > 1

      # --- レース名 ---
      race_name = td2_element.at_css("strong, b")&.text&.strip

      # --- 開催地 ---
      location_match = td2_text.match(/\((.+?)\)/)
      location = location_match ? location_match[1] : nil

      # --- レース距離 ---
      distance_match = td2_text.match(/【(.+?)】/)
      distance = distance_match ? distance_match[1] : nil

      # --- ホームページのリンク ---
      official_url = td2_element.at_css("a")&.[]("href")

      # puts "・#{race_date_start}_#{race_date_end}_#{race_name}_#{location}_#{distance}_#{official_url}"

      if race_name
        races_data << {
          name: race_name,
          date_start: race_date_start,
          date_end: race_date_end,
          location: location,
          distance: distance,
          official_url: official_url,
          scraped_from_url: TRAILRUNNER_JP_TAIKAI_URL,
          scraped_at: Time.current
        }
      else
        puts "警告: 必須情報が取得できませんでした - #{race_element.to_s.gsub(/\s+/, " ").strip[0..100]}..."
      end
    end

    # データベースへの保存
    races_data.each do |data|
      # 既に存在するレース（nameとdate_startが一致）は更新、存在しない場合は新規作成
      Race.find_or_initialize_by(name: data[:name], date_start: data[:date_start]).tap do |race|
        race.assign_attributes(data)
        if race.new_record? || race.changed?
          if race.save
            puts "保存/更新しました: #{race.name} (#{race.date_start})"
          else
            puts "保存に失敗しました: #{race.name} - #{race.errors.full_messages.join(", ")}"
          end
        else
          puts "変更なし: #{race.name} (#{race.date_start})"
        end
      end
      
    end

    puts "TrailRunner.JPからのスクレイピングが完了しました。"
  rescue => e
    puts "スクレイピング中にエラーが発生しました: #{e.message}"
    puts e.backtrace.join("\n")
  end

  private

  # "MM月DD日" 形式の文字列からDateオブジェクトを生成するヘルパーメソッド
  def self.parse_date_from_string(date_str, year)
    return nil unless date_str

    # "MM月DD日" or "MM月DD" のパターンにマッチ
    match_data = date_str.match(/(\d+)月(\d+)日?/)
    return nil unless match_data

    month = match_data[1].to_i
    day = match_data[2].to_i
    Date.new(year, month, day)
  rescue ArgumentError
    nil # 例: Date.new(2024, 2, 30) のような不正な日付の場合
  end
end