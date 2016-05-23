module StackMaster
  class PagedResponseAccumulator
    def self.call(*args)
      new(*args).call
    end

    def initialize(cf, method, arguments, accumulator_method)
      @cf = cf
      @method = method
      @arguments = arguments
      @accumulator_method = accumulator_method
    end

    def call
      book = []
      next_token = nil
      first_response = nil
      begin
        response = @cf.public_send(@method, @arguments.merge(next_token: next_token))
        first_response = response if first_response.nil?
        next_token = response.next_token
        book += response.public_send(@accumulator_method)
      end while !next_token.nil?
      first_response.send("#{@accumulator_method}=", book.reverse)
      first_response.send(:next_token=, book.reverse)
      first_response
    end
  end
end
