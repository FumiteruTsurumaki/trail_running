class CreateKnowledges < ActiveRecord::Migration[7.1]
  def change
    create_table :knowledges do |t|
      t.string :title
      t.text :content
      t.string :category

      t.timestamps
    end
  end
end
