class TranscriptString < AttributedString

  def add_attrs(*args, _force: false, **kwargs)
    unless _force == true
      raise ArgumentError, "safe is not settable without _force: true" if kwargs.has_key?(:safe)
      raise ArgumentError, "finalized is not settable without _force: true" if kwargs.has_key?(:finalized)
    end
    super(*args, **kwargs)
  end


  def safe_concat(string)
    if string.is_a?(AttributedString)
      string.add_attrs(0..string.length, safe: true)
    else
      string = AttributedString.new(string, safe: true)
    end
    self.concat(string)
  end


end
