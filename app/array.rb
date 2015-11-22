class Array

  def cycled_each(from = 0)
    i = from
    begin
      el = self[i]
      yield el
      i = (i+1) % self.count
    end while i != from
  end

end
