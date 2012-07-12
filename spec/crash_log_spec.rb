require 'spec_helper'

describe CrashLog do
  describe '.notify' do
    it 'handles being passed an exception object'
    it 'handles being passed an exception object and user data'
    it 'handles being passed a string'
  end

  describe '.logger' do
    it 'detects Rails.logger'
    it 'defaults to STDOUT'
  end

  describe '.configuration' do
    it 'handles being configured with a block'
    it 'handles directly configuring attributes'
  end

  describe '.ready' do
    it 'logs an ready message' do
      CrashLog.should_receive(:info).with("CrashLog initialized and ready to handle exceptions")
      CrashLog.report_for_duty!
    end
  end
end
