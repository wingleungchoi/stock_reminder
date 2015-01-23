class StocksController < ApplicationController
  def front
    @stock = Stock.first
  end

  def search
    if   params[:stock_number] != "" && (1..10).include?(params[:stock_number].to_i)
      @stock = Stock.find_by(stock_number: params[:stock_number])
      render 'front'
    else
      flash.now[:danger] = "Sorry, we only accept enquiries about stock numbers from 0 to 10."      
      render 'front'
    end
  end
end