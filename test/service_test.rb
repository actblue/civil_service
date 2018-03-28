require "test_helper"

class ServiceTest < Minitest::Spec
  class MyService < CivilService::Service
    validate :ensure_valid

    def initialize(valid: true, should_fail: false)
      @valid = valid
      @should_fail = should_fail
    end

    private

    def inner_call
      if @should_fail
        errors = ActiveModel::Errors.new(self)
        errors.add(:base, "Told to fail")
        failure(errors)
      else
        success
      end
    end

    def ensure_valid
      return if @valid
      errors.add(:valid, "must be true")
    end
  end

  class CustomResultService < CivilService::Service
    class Result < CivilService::Result
    end

    self.result_class = CustomResultService::Result

    private

    def inner_call
      success
    end
  end

  it 'returns a successful result object' do
    result = MyService.new.call
    assert result.is_a?(CivilService::Result)
    assert result.success?
  end

  describe 'failure' do
    let(:service) { MyService.new(should_fail: true) }

    it 'returns a failing result object' do
      result = service.call
      assert result.is_a?(CivilService::Result)
      assert result.failure?
    end

    it 'raises if called with call!' do
      assert_raises(CivilService::ServiceFailure) do
        service.call!
      end
    end
  end

  describe 'validations' do
    let(:service) { MyService.new(valid: false) }

    it 'returns errors' do
      refute service.valid?
    end

    it 'fails if validations fail' do
      result = service.call
      assert result.failure?
    end

    it 'skips validations if validate_manually is set' do
      begin
        MyService.validate_manually = true
        result = service.call
        assert result.success?
      ensure
        MyService.validate_manually = false
      end
    end
  end

  describe 'custom result classes' do
    let(:service) { CustomResultService.new }

    it 'returns the custom result class' do
      result = service.call
      assert result.is_a?(CustomResultService::Result)
    end
  end
end
