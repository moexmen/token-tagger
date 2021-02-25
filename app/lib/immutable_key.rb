class ImmutableKey < String 
  def capitalize 
        self 
  end 
  
  def to_s
   self 
  end 
  
  alias_method :to_str, :to_s
end
