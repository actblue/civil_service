module CivilService::MultiResultService
  extend ActiveSupport::Concern

  class MultiResult < CivilService::Result
    attr_accessor :results

    def success?
      (results || []).compact.all?(&:success)
    end

    def errors
      errors = ActiveModel::Errors.new(self)
      (results || []).compact.each do |result|
        next if result.success?
        result.errors.each do |attribute, error|
          errors.add(attribute, error)
        end
      end
      errors
    end

    def exception
      super || (results || []).compact.map(&:exception).compact.first
    end
  end

  def multi_result(results)
    self.class.result_class.new(results: results)
  end

  class_methods do
    def result_class=(result_class)
      unless result_class <= CivilService::MultiResultService::MultiResult
        raise 'In a MultiResultService, result_class must be a MultiResult'
      end

      @result_class = result_class
    end
  end

  included do
    self.result_class = CivilService::MultiResultService::MultiResult
  end
end
