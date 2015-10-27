require 'uri'


module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = Hash.new
      @params.merge!(route_params)
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
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
  end
end
