# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: provider_parallels_app
#
# Copyright 2015 Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/mixin/shell_out'
require 'chef/provider/lwrp_base'
require_relative 'resource_parallels_app'

class Chef
  class Provider
    # A parent Chef provider for the Parallels app.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ParallelsApp < Provider::LWRPBase
      PATH ||= '/Applications/Parallels Desktop.app'

      use_inline_resources

      provides :parallels_app, platform_family: 'mac_os_x'

      include Chef::Mixin::ShellOut

      #
      # WhyRun is supported by this provider.
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Use a dmg_package resource to download and install the app.
      #
      action :install do
        download_package
        mount_package
        install_package
        unmount_package
      end

      #
      # Use an execute resource to call Parallels' included uninstall script.
      #
      action :remove do
        un = ::File.join(PATH, 'Contents/MacOS/Uninstaller').gsub(' ', '\\ ')
        execute 'Uninstall Parallels' do
          command "#{un} remove"
          action :run
          only_if { ::File.exist?(PATH) }
        end
      end

      private

      #
      # Use an execute resource to call hdiutil and unmount the .dmg package.
      #
      def unmount_package
        dmg = download_path
        cmd = "hdiutil detach '/Volumes/Parallels Desktop #{version}' || " \
              "hdiutil detach '/Volumes/Parallels Desktop #{version}' -force"
        execute 'Unmount Parallels .dmg package' do
          command cmd
          action :run
          only_if "hdiutil info | grep -q 'image-path.*#{dmg}'"
        end
      end

      #
      # Use an execute resource to run the package's included install script.
      #
      def install_package
        init = ::File.join("/Volumes/Parallels Desktop #{version}",
                           ::File.basename(PATH),
                           'Contents/MacOS/inittool').gsub(' ', '\\ ')
        execute 'Run Parallels installer' do
          command "#{init} install -t '#{PATH}'"
          creates PATH
          action :run
        end
      end

      #
      # Use an execute resource to call hdiutil and mount the .dmg package.
      #
      def mount_package
        dmg = download_path
        execute 'Mount Parallels .dmg package' do
          command "hdiutil attach '#{dmg}'"
          action :run
          not_if "hdiutil info | grep -q 'image-path.*#{dmg}'"
          not_if { ::File.exist?(PATH) }
        end
      end

      #
      # Use a remote_file resource to download the .dmg package.
      #
      def download_package
        s = remote_path
        remote_file download_path do
          source s
          action :create
          not_if { ::File.exist?(PATH) }
        end
      end

      #
      # Construct a .dmg file download path under Chef's cache dir.
      #
      # @return [String] a local path to download Parallels to
      #
      def download_path
        ::File.join(Chef::Config[:file_cache_path],
                    ::File.basename(remote_path))
      end

      #
      # Use the resource's version attribute to construct a Parallels URL,
      # then follow the redirect to a .dmg file.
      #
      # @return [String] a download URL
      #
      def remote_path
        @remote_path ||= begin
          # While www. is served up over HTTPS, it still redirects to an HTTP
          # download, so let's not bother with configuring SSL.
          uri = URI("http://www.parallels.com/directdownload/pd#{version}/")
          Net::HTTP.get_response(uri)['location']
        end
      end

      #
      # Return either the new_resource's version or, eventually, have logic
      # that can dynamically figure out what the latest major version is.
      #
      # @return [String] a version string for this provider to use
      #
      def version
        new_resource.version # TODO: || Parallels::Helpers.latest_version
      end
    end
  end
end
