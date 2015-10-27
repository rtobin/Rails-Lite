require 'uri'

def parse_www_encoded_form(www_encoded_form)
  arr = URI.decode_www_form(www_encoded_form).flatten
  result = Hash.new
  Hash[*arr].each do |key, val|
    arr = parse_key(key)
    result = get_some_hash(result, arr, val)
  end

  result
end

def get_some_hash(hash, arr, val)
  # arr = ['user', 'address', 'street']
  if arr.count == 1
    hash[arr.first] = val
  elsif hash[arr.first]
    hash[arr.first].merge(get_some_hash(hash[arr.first], arr[1..-1], val))
  else
    hash[arr.first] = get_some_hash({}, arr[1..-1], val)
  end

  hash
end


# this should return an array
# user[address][street] should return ['user', 'address', 'street']
def parse_key(key)
  key.split(/\]\[|\[|\]/)
end
