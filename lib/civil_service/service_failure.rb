class CivilService::ServiceFailure < StandardError
  attr_reader :service, :result

  def initialize(service, result)
    @service = service
    @result = result
    super("#{service.class.name} failed: #{result.errors.full_messages.join(', ')}")
  end
end
