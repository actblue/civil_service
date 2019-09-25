require "test_helper"

class ServiceTest < Minitest::Spec
  class MyService < CivilService::Service
    validate :ensure_valid

    def initialize(valid: true, should_fail: false, should_raise: false)
      @valid = valid
      @should_fail = should_fail
      @should_raise = should_raise
    end

    private

    def inner_call
      raise 'Raising exception as instructed' if @should_raise

      if @should_fail
        result = failure(errors)
        result.errors.add(:base, "Told to fail")
        result
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
      attr_accessor :magic_number
    end

    self.result_class = CustomResultService::Result

    private

    def inner_call
      success magic_number: 42
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

  describe 'error' do
    let(:service) { MyService.new(should_raise: true) }

    it 'returns a failing result object' do
      result = service.call
      assert result.is_a?(CivilService::Result)
      assert result.failure?
      assert_equal ['Raising exception as instructed'], result.errors.full_messages
      assert result.exception.message == 'Raising exception as instructed'
    end

    it 'raises if called with call!' do
      assert_raises(RuntimeError) do
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
      assert_equal 42, result.magic_number
    end
  end
end
