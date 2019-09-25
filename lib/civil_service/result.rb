class CivilService::Result
  include ActiveModel::Model
  attr_accessor :success, :exception
  attr_writer :errors

  def self.success(attributes = {})
    new(attributes.merge(success: true))
  end

  def self.failure(attributes = {})
    new(attributes.merge(success: false))
  end

  def success?
    @success
  end

  def failure?
    !success?
  end

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end
end
