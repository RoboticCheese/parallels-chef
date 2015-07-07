# Encoding: UTF-8

require_relative '../spec_helper'

describe 'parallels::app' do
  describe file('/Applications/Parallels Desktop.app') do
    it 'exists' do
      expect(subject).to be_directory
    end
  end
end
