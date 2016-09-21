module Utils
  def self.stringify_keys(hash)
    new_hash = {}
    hash.each do |k, v|
      new_hash[k.to_s] = v
    end
    new_hash
  end
end
