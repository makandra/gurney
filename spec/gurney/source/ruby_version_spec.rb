describe Gurney::Source::RubyVersion do

  describe 'dependencies' do
    it 'parses a .ruby-version file' do
      bundler = described_class.new(ruby_version: File.read('spec/fixtures/test_project/.ruby-version'))
      dependencies = bundler.dependencies

      expect(dependencies.count).to eq 1
      expect(dependencies[0]).to have_attributes(class: Gurney::Dependency, ecosystem: 'ruby', name: 'ruby', version: '2.3.8')
    end
  end

end
