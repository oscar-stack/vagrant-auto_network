require 'spec_helper'
require 'auto_network/settings'

describe AutoNetwork::Settings do
  subject {
    Module.new do
      extend AutoNetwork::Settings
    end
  }

  describe 'default_pool' do

    it 'returns DEFAULT_POOL if nothing has been set' do
      expect(subject.default_pool).to eq(AutoNetwork::Settings::DEFAULT_POOL)
    end

    it 'raises an error when set to an invalid value' do
      expect { subject.default_pool=nil }.to raise_error(AutoNetwork::Settings::InvalidSettingErrror)
    end

  end

  describe 'pool_manager' do
    context 'when unset' do
      it 'raises an error when accessed through active_pool_manager' do
        expect { subject.active_pool_manager }.to raise_error(AutoNetwork::Settings::InvalidSettingErrror)
      end
    end
  end
end
