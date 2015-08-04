# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_parallels_config'

describe Chef::Provider::ParallelsConfig do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::ParallelsConfig.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe '.provides?' do
    let(:platform) { nil }
    let(:node) { ChefSpec::Macros.stub_node('node.example', platform) }
    let(:res) { described_class.provides?(node, new_resource) }

    context 'Mac OS X' do
      let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#action_create' do
    let(:new_resource) do
      r = super()
      r.license('abcd')
      r
    end

    it 'uses an execute resource' do
      p = provider
      expect(p).to receive(:execute).with('Install Parallels license')
        .and_yield
      expect(p).to receive(:command).with('/Applications/Parallels\\ ' \
                                          'Desktop.app/Contents/MacOS/' \
                                          'prlsrvctl install-license -k abcd')
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:only_if)
      expect(p).to receive(:not_if).with('/Applications/Parallels\\ ' \
                                         'Desktop.app/Contents/MacOS/' \
                                         'prlsrvctl info --license | grep ' \
                                         '\'status="ACTIVE"\'')
      p.action_create
    end
  end
end
