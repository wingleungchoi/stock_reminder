class CreateStock1 < ActiveRecord::Migration
  def change
    create_table :stock1s do |t|
      t.string :date
      t.string :open
      t.string :high
      t.string :low
      t.string :close
      t.string :trading_volume
      t.string :adjusted_close
    end
  end
end
