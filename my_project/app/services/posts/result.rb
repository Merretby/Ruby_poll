module Posts
  class Result
    attr_reader :post, :error

    def initialize(success:, post: nil, error: nil)
      @success = success
      @post = post
      @error = error
    end

    def success?
      @success
    end
  end
end
