require './model/car'
require_relative 'proxy'

class CarProxy < Proxy

  def initialize(car)
    super(car)
  end

end
