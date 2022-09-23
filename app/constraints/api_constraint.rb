class ApiConstraint
  attr_reader :version

  def initialize(options)
    @version = options.fetch(:version)
  end

  def matches?(request)
    Rails.logger.info "\n\nMATCHING #{request.params.inspect}\n\n"
    if request.params[:version]
      request.params[:version].to_i >= @version && request.params[:version].to_i < (@version + 1)
    else
      @version == 1
    end
  end
end
