# Encoding: UTF-8

require_relative '../spec_helper'

describe 'parallels::default' do
  let(:overrides) { {} }
  let(:platform) { { platform: 'mac_os_x', version: '10.10' } }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      overrides.each { |k, v| node.set[k] = v }
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'default attribute' do
    let(:overrides) { {} }

    it 'installs Parallels with a nil version' do
      expect(chef_run).to install_parallels('default').with(version: nil)
    end

    it 'configures Parallels with no license' do
      expect(chef_run).to configure_parallels('default').with(license: nil)
    end
  end

  context 'an overridden version attribute' do
    let(:overrides) { { parallels: { app: { version: '10' } } } }

    it 'installs Parallels with the given version' do
      expect(chef_run).to install_parallels('default').with(version: '10')
    end
  end

  context 'an overridden license attribute' do
    let(:overrides) { { parallels: { config: { license: 'abcd' } } } }

    it 'configures Parallels with the given license' do
      expect(chef_run).to configure_parallels('default').with(license: 'abcd')
    end
  end
end
