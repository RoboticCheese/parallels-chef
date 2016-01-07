# Encoding: UTF-8
#
# Cookbook Name:: parallels
# Library:: resource_parallels_app
#
# Copyright 2015-2016 Jonathan Hartman
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

require 'chef/resource'

class Chef
  class Resource
    # A Chef resource for the Parallels app.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ParallelsApp < Resource
      PATH ||= '/Applications/Parallels Desktop.app'

      provides :parallels_app, platform_family: 'mac_os_x'

      #
      # Allow a user to install a major version of Parallels.
      #
      property :version,
               kind_of: [String, Fixnum, nil],
               default: '11',
               callbacks: { 'Not a valid major version' =>
                              lambda do |a|
                                a.is_a?(Fixnum) || !a.match(/^[0-9]+$/).nil?
                              end }

      default_action :install

      #
      # Use a dmg_package resource to download and install the app.
      #
      action :install do
        remote_file download_path do
          source remote_path
          not_if { ::File.exist?(PATH) }
        end
        execute 'Mount Parallels .dmg package' do
          command "hdiutil attach '#{download_path}'"
          not_if "hdiutil info | grep -q 'image-path.*#{download_path}'"
          not_if { ::File.exist?(PATH) }
        end
        execute 'Run Parallels installer' do
          init = ::File.join("/Volumes/Parallels Desktop #{version}",
                             ::File.basename(PATH),
                             'Contents/MacOS/inittool').gsub(' ', '\\ ')
          command "#{init} install -t '#{PATH}' -s"
          creates PATH
        end
        execute 'Unmount Parallels .dmg package' do
          command "hdiutil detach '/Volumes/Parallels Desktop #{version}' || " \
                  "hdiutil detach '/Volumes/Parallels Desktop #{version}' " \
                  '-force'
          only_if "hdiutil info | grep -q 'image-path.*#{download_path}'"
        end
      end

      #
      # Use an execute resource to call Parallels' included uninstall script.
      #
      action :remove do
        execute 'Uninstall Parallels' do
          un = ::File.join(PATH, 'Contents/MacOS/Uninstaller').gsub(' ', '\\ ')
          command "#{un} remove"
          only_if { ::File.exist?(PATH) }
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
    end
  end
end
