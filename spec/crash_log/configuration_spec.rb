require 'spec_helper'

describe CrashLog::Configuration do
  context 'release stage' do
    it 'includes production' do
      subject.release_stages.should include 'production'
    end

    it 'includes staging' do
      subject.release_stages.should include 'staging'
    end

    it 'is true if production' do
      subject.stage = 'production'
      subject.release_stage?.should be_true
    end

    it 'is true if staging' do
      subject.stage = 'staging'
      subject.release_stage?.should be_true
    end

    it 'is false in development' do
      subject.stage = 'development'
      subject.release_stage?.should be_false
    end
  end

  context 'valid?' do
    it 'is valid if api_key and secret are present' do
      subject.should_not be_valid
      subject.api_key = 'API_KEY'
      subject.secret = 'SECRET'
      subject.should be_valid
    end
  end
end
