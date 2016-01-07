require_relative '../../../spec_helper'

describe 'resource_parallels_app::mac_os_x::10_10' do
  let(:version) { nil }
  let(:action) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'parallels_app',
      platform: 'mac_os_x',
      version: '10.10'
    ) do |node|
      node.set['parallels']['app']['version'] = version unless version.nil?
    end
  end
  let(:converge) { runner.converge("resource_parallels_app_test::#{action}") }

  context 'the default action (:install)' do
    let(:action) { :default }
    let(:installed?) { false }
    let(:mounted?) { false }

    before(:each) do
      allow(Net::HTTP).to receive(:get_response).with(
        URI("http://www.parallels.com/directdownload/pd#{version || 10}/")
      ).and_return('location' => 'http://example.com/parallels.dmg')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?)
        .with('/Applications/Parallels Desktop.app').and_return(installed?)
      stub_command(
        "hdiutil info | grep -q 'image-path.*/tmp/chef/cache/parallels.dmg'"
      ).and_return(mounted?)
    end

    shared_examples_for 'not installed' do
      it 'downloads the Parallels package' do
        expect(chef_run).to create_remote_file(
          '/tmp/chef/cache/parallels.dmg'
        ).with(source: 'http://example.com/parallels.dmg')
      end

      it 'mounts the Parallels package' do
        expect(chef_run).to run_execute('Mount Parallels .dmg package').with(
          command: "hdiutil attach '/tmp/chef/cache/parallels.dmg'"
        )
      end

      it 'runs the Parallels installer' do
        expect(chef_run).to run_execute('Run Parallels installer').with(
          command: "/Volumes/Parallels\\ Desktop\\ #{version || 10}/" \
                   'Parallels\\ Desktop.app/Contents/MacOS/inittool install ' \
                   "-t '/Applications/Parallels Desktop.app' -s",
          creates: '/Applications/Parallels Desktop.app'
        )
      end
    end

    context 'no version attribute' do
      let(:version) { nil }
      cached(:chef_run) { converge }

      it_behaves_like 'not installed'
    end

    context 'a version attribute' do
      let(:version) { '4' }
      cached(:chef_run) { converge }

      it_behaves_like 'not installed'
    end

    context 'already installed' do
      let(:installed?) { true }
      cached(:chef_run) { converge }

      it 'does not downloadd the Parallels package' do
        expect(chef_run).to_not create_remote_file(
          '/tmp/chef/cache/parallels.dmg'
        )
      end

      it 'does not mount the Parallels package' do
        expect(chef_run).to_not run_execute('Mount Parallels .dmg package')
      end
    end

    context 'already mounted' do
      let(:mounted?) { true }
      cached(:chef_run) { converge }

      it 'unmounts the Parallels package' do
        expect(chef_run).to run_execute('Unmount Parallels .dmg package').with(
          command: "hdiutil detach '/Volumes/Parallels Desktop " \
                   "#{version || 10}' || hdiutil detach '/Volumes/Parallels " \
                   "Desktop #{version || 10}' -force"
        )
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }
    let(:installed?) { false }

    before(:each) do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?)
        .with('/Applications/Parallels Desktop.app').and_return(installed?)
    end

    context 'installed' do
      let(:installed?) { true }
      cached(:chef_run) { converge }

      it 'runs the Parallels uninstall script' do
        expect(chef_run).to run_execute('Uninstall Parallels').with(
          command: '/Applications/Parallels\\ Desktop.app/Contents/MacOS/' \
                   'Uninstaller remove'
        )
      end
    end

    context 'not installed' do
      let(:installed?) { false }
      cached(:chef_run) { converge }

      it 'does not run the Parallels uninstall script' do
        expect(chef_run).to_not run_execute('Uninstall Parallels')
      end
    end
  end
end
