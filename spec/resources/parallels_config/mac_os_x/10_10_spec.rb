require_relative '../../../spec_helper'

describe 'resource_parallels_config::mac_os_x::10_10' do
  let(:license) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'parallels_config',
      platform: 'mac_os_x',
      version: '10.10'
    ) do |node|
      node.set['parallels']['config']['license'] = license unless license.nil?
    end
  end
  let(:converge) do
    runner.converge("resource_parallels_config_test::#{action}")
  end

  context 'the default action (:create)' do
    let(:action) { :default }
    let(:active?) { nil }

    before(:each) do
      stub_command('/Applications/Parallels\\ Desktop.app/Contents/MacOS/' \
                   "prlsrvctl info --license | grep 'status=\"ACTIVE\"'")
        .and_return(active?)
    end

    context 'no license attribute' do
      let(:license) { nil }
      cached(:chef_run) { converge }

      it 'does not run the license install script' do
        expect(chef_run).to_not run_execute('Install Parallels license')
      end
    end

    context 'a license attribute' do
      let(:license) { 'abc-123' }

      context 'license not already installed' do
        let(:active?) { false }
        cached(:chef_run) { converge }

        it 'runs the license install script' do
          expect(chef_run).to run_execute('Install Parallels license').with(
            command: '/Applications/Parallels\\ Desktop.app/Contents/MacOS/' \
                     'prlsrvctl install-license -k abc-123'
          )
        end
      end

      context 'license already installed' do
        let(:active?) { true }
        cached(:chef_run) { converge }

        it 'does not run the license install script' do
          expect(chef_run).to_not run_execute('Install Parallels license')
        end
      end
    end
  end
end
