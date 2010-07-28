class CreateMonthreports < ActiveRecord::Migration
  def self.up
    create_table :monthreports do |t|
      t.date :date
      t.decimal :expenses, :precision => 9, :scale => 2, :null => false, :default => 0.00
      t.decimal :income, :precision => 9, :scale => 2, :null => false, :default => 0.00
      t.integer :account_id
      t.decimal :saldo, :precision => 9, :scale => 2, :null => false, :default => 0.00

      t.timestamps
    end
  end

  def self.down
    drop_table :monthreports
  end
end
