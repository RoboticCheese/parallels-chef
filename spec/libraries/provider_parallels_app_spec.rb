# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_parallels_app'

describe Chef::Provider::ParallelsApp do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::ParallelsApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe 'PATH' do
    it 'returns the app directory' do
      expected = '/Applications/Parallels Desktop.app'
      expect(described_class::PATH).to eq(expected)
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#action_install' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:remote_path)
        .and_return('http://example.com/parallels.dmg')
      allow_any_instance_of(described_class).to receive(:version)
        .and_return('9')
    end

    it 'uses a dmg_package to install Parallels' do
      p = provider
      expect(p).to receive(:dmg_package).with('Parallels Desktop').and_yield
      expect(p).to receive(:source).with('http://example.com/parallels.dmg')
      expect(p).to receive(:volumes_dir).with('Parallels Desktop 9')
      expect(p).to receive(:action).with(:install)
      p.action_install
    end
  end

  describe '#action_remove' do
    it 'removes all the Parallels directories' do
      p = provider
      [
        described_class::PATH,
        '/Applications/Parallels Access.app'
      ].each do |d|
        expect(p).to receive(:directory).with(d).and_yield
        expect(p).to receive(:recursive).with(true)
        expect(p).to receive(:action).with(:delete)
      end
      p.action_remove
    end
  end

  describe '#remote_path' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:version)
        .and_return('9')
      allow(Net::HTTP).to receive(:get_response)
        .with(URI('http://www.parallels.com/directdownload/pd9/'))
        .and_return('location' => 'http://example.com/parallels.dmg')
    end

    it 'returns a download URL' do
      expected = 'http://example.com/parallels.dmg'
      expect(provider.send(:remote_path)).to eq(expected)
    end
  end

  describe '#version' do
    context 'no resource version override' do
      it 'returns the default version' do
        expect(provider.send(:version)).to eq('10')
      end
    end

    context 'a resource version override' do
      let(:new_resource) do
        r = super()
        r.version('9')
        r
      end

      it 'returns the overridden version' do
        expect(provider.send(:version)).to eq('9')
      end
    end
  end
end
