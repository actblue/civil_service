class CivilService::Service
  include ActiveModel::Validations

  attr_writer :logger

  class << self
    attr_accessor :validate_manually
    attr_writer :result_class

    def result_class
      @result_class || CivilService::Result
    end
  end

  def call(validate: true)
    if validate && !self.class.validate_manually
      return failure(errors) unless valid?
    end

    begin
      inner_call
    rescue StandardError => exception
      errors.add :base, exception.message
      failure(errors, exception: exception)
    end
  end

  def call_and_raise(validate: true)
    result = call(validate: validate)
    if result.exception
      raise result.exception, result.exception.message, result.exception.backtrace
    end

    result
  end

  def call!(validate: true)
    if validate && !self.class.validate_manually
      raise CivilService::ServiceFailure.new(self, failure(errors)) unless valid?
    end

    result = call_and_raise(validate: false) # we already just did the validation step if needed
    raise CivilService::ServiceFailure.new(self, result) if result.failure?
    result
  end

  def logger
    @logger || Rails.logger
  end

  private

  def success(attributes = {})
    self.class.result_class.success(attributes)
  end

  def failure(errors, attributes = {})
    self.class.result_class.failure(attributes.merge(errors: errors))
  end

  def inner_call
    raise 'Service classes are expected to implement #inner_call'
  end
end
