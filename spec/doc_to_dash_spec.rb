require 'spec_helper'

describe 'doc_to_dash' do

  # test the default plist generation based on the presence of index.html or frames.html
  describe 'default_plist' do
    before :all do
      FileUtils.mkdir_p 'tmp'
    end

    it 'should generate plist without index.html or frames.html' do
      FileUtils.rm_f "tmp/index.html"
      FileUtils.rm_f "tmp/frames.html"
      dg = DocToDash::DocsetGenerator.new({:doc_input_path => 'tmp', :doc_save_folder => 'tmp', :index_file => nil})
      plist = dg.send 'default_plist'
      plist.should_not match(%r{<key>dashIndexFilePath</key>})
      plist.should_not match(%r{<string>tmp/index.html</string>})
      plist.should_not match(%r{<string>tmp/frames.html</string>})
    end

    it 'should generate plist with index.html when only index.html exists' do
      FileUtils.touch "tmp/index.html"
      FileUtils.rm_f "tmp/frames.html"
      dg = DocToDash::DocsetGenerator.new({:doc_input_path => 'tmp', :doc_save_folder => 'tmp', :index_file => 'index.html'})
      plist = dg.send 'default_plist'
      plist.should match(%r{<key>dashIndexFilePath</key>})
      plist.should match(%r{<string>tmp/index.html</string>})
      plist.should_not match(%r{<string>tmp/frames.html</string>})
    end

    it 'should generate plist with frames.html when only frames.html exists' do
      FileUtils.rm_f "tmp/index.html"
      FileUtils.touch "tmp/frames.html"
      dg = DocToDash::DocsetGenerator.new({:doc_input_path => 'tmp', :doc_save_folder => 'tmp', :index_file => 'frames.html'})
      plist = dg.send 'default_plist'
      plist.should match(%r{<key>dashIndexFilePath</key>})
      plist.should match(%r{<string>tmp/frames.html</string>})
      plist.should_not match(%r{<string>tmp/index.html</string>})
    end

    it 'should generate plist with frames.html when both index.html and frames.html exist' do
      FileUtils.rm_f "tmp/index.html"
      FileUtils.touch "tmp/frames.html"
      dg = DocToDash::DocsetGenerator.new({:doc_input_path => 'tmp', :doc_save_folder => 'tmp', :index_file => 'frames.html'})
      plist = dg.send 'default_plist'
      plist.should match(%r{<key>dashIndexFilePath</key>})
      plist.should match(%r{<string>tmp/frames.html</string>})
      plist.should_not match(%r{<string>tmp/index.html</string>})
    end
  end
end