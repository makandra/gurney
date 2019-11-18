describe Gurney::Source::Bundler do

  describe 'dependencies' do
    it 'parses correct bundler lockfiles' do
      bundler = Gurney::Source::Bundler.new(gemfile_lock: File.read('spec/fixtures/test_project/Gemfile.lock'))
      dependencies = bundler.dependencies

      expect(dependencies.count).to eq 5
      expect(dependencies[0]).to have_attributes(class: Gurney::Dependency, ecosystem: 'rubygems', name: 'byebug', version: '11.0.1')
      expect(dependencies[1]).to have_attributes(class: Gurney::Dependency, ecosystem: 'rubygems', name: 'httparty', version: '0.17.1')
      expect(dependencies[2]).to have_attributes(class: Gurney::Dependency, ecosystem: 'rubygems', name: 'mime-types', version: '3.3')
      expect(dependencies[3]).to have_attributes(class: Gurney::Dependency, ecosystem: 'rubygems', name: 'mime-types-data', version: '3.2019.1009')
      expect(dependencies[4]).to have_attributes(class: Gurney::Dependency, ecosystem: 'rubygems', name: 'multi_xml', version: '0.6.0')
    end
  end

end
