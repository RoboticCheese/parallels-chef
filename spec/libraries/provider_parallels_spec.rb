# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_parallels'

describe Chef::Provider::Parallels do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::Parallels.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe 'PATH' do
    it 'returns the app directory' do
      expected = '/Applications/Parallels Desktop.app'
      expect(described_class::PATH).to eq(expected)
    end
  end

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

  describe '#action_install' do
    let(:version) { nil }
    let(:new_resource) do
      r = super()
      r.version(version) unless version.nil?
      r
    end

    context 'no version provided' do
      let(:version) { nil }

      it 'uses an empty parallels_app resource' do
        p = provider
        expect(p).to receive(:parallels_app).with('default').and_yield
        expect(p).to receive(:version).with('10')
        expect(p).to receive(:action).with(:install)
        p.action_install
      end
    end

    context 'a version provided' do
      let(:version) { '9' }

      it 'passes the version on to a parallels_app resource' do
        p = provider
        expect(p).to receive(:parallels_app).with('default').and_yield
        expect(p).to receive(:version).with('9')
        expect(p).to receive(:action).with(:install)
        p.action_install
      end
    end
  end

  describe '#action_remove' do
    it 'uses the parallels_app resource' do
      p = provider
      expect(p).to receive(:parallels_app).with('default').and_yield
      expect(p).to receive(:action).with(:remove)
      p.action_remove
    end
  end

  describe '#action_configure' do
    let(:license) { nil }
    let(:new_resource) do
      r = super()
      r.license(license) unless license.nil?
      r
    end

    context 'no license provided' do
      let(:license) { nil }

      it 'uses an empty parallels_config resource' do
        p = provider
        expect(p).to receive(:parallels_config).with('default').and_yield
        expect(p).to receive(:license).with(nil)
        expect(p).to receive(:action).with(:create)
        p.action_configure
      end
    end

    context 'a license provided' do
      let(:license) { '1234-5678-9101-1213' }

      it 'passes the license on to a parallels_config resource' do
        p = provider
        expect(p).to receive(:parallels_config).with('default').and_yield
        expect(p).to receive(:license).with('1234-5678-9101-1213')
        expect(p).to receive(:action).with(:create)
        p.action_configure
      end
    end
  end
end
