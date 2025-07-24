class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.integer :quantity
      t.boolean :out_of_stock
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
