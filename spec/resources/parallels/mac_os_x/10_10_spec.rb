require_relative '../../../spec_helper'

describe 'resource_parallels::mac_os_x::10_10' do
  let(:version) { nil }
  let(:license) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'parallels',
      platform: 'mac_os_x',
      version: '10.10'
    ) do |node|
      node.set['parallels']['app']['version'] = version unless version.nil?
      node.set['parallels']['config']['license'] = license unless license.nil?
    end
  end
  let(:converge) { runner.converge("resource_parallels_test::#{action}") }

  context 'the default action (:install)' do
    let(:action) { :default }

    shared_examples_for 'any attribute set' do
      it 'installs the Parallels app' do
        expect(chef_run).to install_parallels_app('default')
          .with(version: (version || '11'))
      end
    end

    context 'no version attribute' do
      let(:version) { nil }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'a version attribute' do
      let(:version) { '4' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }
    cached(:chef_run) { converge }

    it 'removes the Parallels app' do
      expect(chef_run).to remove_parallels_app('default')
    end
  end

  context 'the :configure action' do
    let(:action) { :configure }

    shared_examples_for 'any attribute set' do
      it 'configures Parallels' do
        expect(chef_run).to create_parallels_config('default')
          .with(license: license)
      end
    end

    context 'no license attribute' do
      let(:license) { nil }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'a license attribute' do
      let(:license) { 'abc-123' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end
  end
end
