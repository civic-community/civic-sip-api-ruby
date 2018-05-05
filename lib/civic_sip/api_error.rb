module CivicSIP
  class APIError < StandardError
    attr_reader :http_code

    def initialize(http_code, message)
      super message

      @http_code = http_code
    end
  end
end