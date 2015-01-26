class CreateDailyPrices < ActiveRecord::Migration
  def change
    create_table :daily_prices do |t|
      t.integer :stock_number
      t.string :date
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.integer :trading_volume
      t.float :adjusted_close
      t.float :moving_250
      t.float :moving_25
      t.timestamps
    end
  end
end
