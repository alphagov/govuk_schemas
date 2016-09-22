module Utils
  def self.stringify_keys(hash)
    new_hash = {}
    hash.each do |k, v|
      new_hash[k.to_s] = v
    end
    new_hash
  end

  def self.parameterize(string)
    string.gsub(/[^a-z0-9\-_]+/i, '-')
  end
end
