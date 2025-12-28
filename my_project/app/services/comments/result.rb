module Comments
  class Result
    attr_reader :comment, :error, :error_code

    def initialize(success:, comment: nil, error: nil, error_code: nil)
      @success = success
      @comment = comment
      @error = error
      @error_code = error_code
    end

    def success?
      @success
    end
  end
end
