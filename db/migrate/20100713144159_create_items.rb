class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.integer :account_id
      t.decimal :amount, :precision => 9, :scale => 2
      t.string :payee
      t.string :description
      t.string :uid

      t.timestamps
    end
  end

  def self.down
    drop_table :items
  end
end
