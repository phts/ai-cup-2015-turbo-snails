class Proxy
  attr_reader :subject

  def initialize(subject)
    @subject = subject
  end

  def method_missing(method_sym, *arguments, &block)
    subject.send(method_sym, *arguments, &block)
  end

end
