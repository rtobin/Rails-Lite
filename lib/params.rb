require 'uri'

class Params
  #  merge params from
  # 1. query string  ✓
  # 2. post body     ✓
  # 3. route params  ✓
  def initialize(req, route_params = {})
    @params = Hash.new
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
    @params.merge!(route_params)
  end

  def [](key)
    @params[key.to_sym] || @params[key.to_s]
  end

  # this will be useful if we want to `puts params` in the server log
  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    arr = URI.decode_www_form(www_encoded_form).flatten
    result = {}
    Hash[*arr].each do |key, val|
      result = get_some_hash(result, parse_key(key), val)
    end

    result
  end

  # recursively dive in to a nested hash and assign/merge key vals
  def get_some_hash(hash, arr, val)
    if arr.count == 1
      hash[arr.first] = val
    elsif hash[arr.first]
      scope_hash = get_some_hash(hash[arr.first], arr[1..-1], val)
      hash[arr.first].merge(scope_hash)
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
end
