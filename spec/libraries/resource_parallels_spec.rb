# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_parallels_app'

describe Chef::Resource::Parallels do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:resource) { described_class.new(name, run_context) }

  describe '#initialize' do
    it 'sets the correct resource name' do
      expect(resource.resource_name).to eq(:parallels)
    end

    it 'sets the correct supported actions' do
      expected = [:nothing, :install, :remove, :configure]
      expect(resource.allowed_actions).to eq(expected)
    end

    it 'sets the correct default action' do
      expect(resource.action).to eq([:install, :configure])
    end
  end

  describe '#version' do
    let(:version) { nil }
    let(:resource) do
      r = super()
      r.version(version) unless version.nil?
      r
    end

    context 'default' do
      let(:version) { nil }

      it 'returns 10' do
        expect(resource.version).to eq('10')
      end
    end

    context 'a valid override' do
      let(:version) { '9' }

      it 'returns the override' do
        expect(resource.version).to eq('9')
      end
    end

    context 'an invalid override' do
      let(:version) { '1.2' }

      it 'raises an error' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe '#license' do
    let(:license) { nil }
    let(:resource) do
      r = super()
      r.license(license) unless license.nil?
      r
    end

    context 'default' do
      let(:license) { nil }

      it 'returns nil' do
        expect(resource.license).to eq(nil)
      end
    end

    context 'a valid override' do
      let(:license) { '1234-5678-9101-1213' }

      it 'returns the override' do
        expect(resource.license).to eq('1234-5678-9101-1213')
      end
    end

    context 'an invalid override' do
      let(:license) { true }

      it 'raises an error' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
