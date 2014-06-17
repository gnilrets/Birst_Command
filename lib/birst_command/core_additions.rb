class String
  # Strip leading whitespace from each line that is the same as the 
  # amount of whitespace on the first line of the string.
  # Leaves _additional_ indentation on later lines intact.
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

class Object
  def symbolize_keys
    return self.inject({}){|memo,(k,v)| memo[k.to_sym] = v.symbolize_keys; memo} if self.is_a? Hash
    return self.inject([]){|memo,v    | memo           << v.symbolize_keys; memo} if self.is_a? Array
    return self
  end
end
