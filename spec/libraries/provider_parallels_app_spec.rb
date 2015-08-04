# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_parallels_app'

describe Chef::Provider::ParallelsApp do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::ParallelsApp.new(name, nil) }
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

  describe '#action_install' do
    it 'downloads, mounts, installs, and unmounts the package' do
      p = provider
      [
        :download_package, :mount_package, :install_package, :unmount_package
      ].each do |m|
        expect(p).to receive(m)
      end
      p.action_install
    end
  end

  describe '#action_remove' do
    it 'runs the uninstall script' do
      p = provider
      expect(p).to receive(:execute).with('Uninstall Parallels').and_yield
      expect(p).to receive(:command).with('/Applications/Parallels\\ Desktop' \
                                          '.app/Contents/MacOS/Uninstaller ' \
                                          'remove')
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:only_if).and_yield
      expect(File).to receive(:exist?)
        .with('/Applications/Parallels Desktop.app')
      p.action_remove
    end
  end

  describe '#unmount_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/parallels.dmg')
      allow_any_instance_of(described_class).to receive(:version).and_return(4)
    end

    it 'unmounts the .dmg package' do
      p = provider
      expect(p).to receive(:execute).with('Unmount Parallels .dmg package')
        .and_yield
      expect(p).to receive(:command).with("hdiutil detach '/Volumes/" \
                                          "Parallels Desktop 4' || " \
                                          "hdiutil detach '/Volumes/" \
                                          "Parallels Desktop 4' -force")
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:only_if)
        .with("hdiutil info | grep -q 'image-path.*/tmp/parallels.dmg'")
      p.send(:unmount_package)
    end
  end

  describe '#install_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:version).and_return(4)
    end

    it 'runs the installer script' do
      p = provider
      expect(p).to receive(:execute).with('Run Parallels installer').and_yield
      expect(p).to receive(:command).with('/Volumes/Parallels\\ Desktop\\ 4/' \
                                          'Parallels\\ Desktop.app/Contents/' \
                                          'MacOS/inittool install -t ' \
                                          "'/Applications/Parallels Desktop" \
                                          ".app' -s")
      expect(p).to receive(:creates).with('/Applications/Parallels Desktop.app')
      expect(p).to receive(:action).with(:run)
      p.send(:install_package)
    end
  end

  describe '#mount_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/parallels.dmg')
    end

    it 'mounts the .dmg package' do
      p = provider
      expect(p).to receive(:execute).with('Mount Parallels .dmg package')
        .and_yield
      expect(p).to receive(:command).with("hdiutil attach '/tmp/parallels.dmg'")
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:not_if)
        .with("hdiutil info | grep -q 'image-path.*/tmp/parallels.dmg'")
      expect(p).to receive(:not_if).and_yield
      expect(File).to receive(:exist?)
        .with('/Applications/Parallels Desktop.app')
      p.send(:mount_package)
    end
  end

  describe '#download_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:remote_path)
        .and_return('http://example.com/parallels.dmg')
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/parallels.dmg')
    end

    it 'downloads the .dmg package' do
      p = provider
      expect(p).to receive(:remote_file).with('/tmp/parallels.dmg').and_yield
      expect(p).to receive(:source).with('http://example.com/parallels.dmg')
      expect(p).to receive(:action).with(:create)
      expect(p).to receive(:not_if).and_yield
      expect(File).to receive(:exist?)
        .with('/Applications/Parallels Desktop.app')
      p.send(:download_package)
    end
  end

  describe '#download_path' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:remote_path)
        .and_return('http://example.com/parallels.dmg')
    end

    it 'returns a path in the Chef cache path' do
      expected = "#{Chef::Config[:file_cache_path]}/parallels.dmg"
      expect(provider.send(:download_path)).to eq(expected)
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
