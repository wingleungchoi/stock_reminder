class Stock < ActiveRecord::Base
  has_many :daily_prices
end