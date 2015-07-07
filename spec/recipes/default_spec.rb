# Encoding: UTF-8

require_relative '../spec_helper'

describe 'parallels::default' do
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::SoloRunner.new do |node|
      overrides.each { |k, v| node.set[k] = v }
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'default attribute' do
    let(:overrides) { {} }

    it 'installs Parallels with version 10' do
      expect(chef_run).to install_parallels_app('default').with(version: '10')
    end
  end

  context 'an overridden version attribute' do
    let(:overrides) { { parallels: { version: '9' } } }

    it 'installs parallels with the given version' do
      expect(chef_run).to install_parallels_app('default').with(version: '9')
    end
  end
end
