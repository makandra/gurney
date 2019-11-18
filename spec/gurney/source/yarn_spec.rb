describe Gurney::Source::Yarn do

  describe 'dependencies' do
    it 'parses correct yarn lockfiles' do
      yarn = Gurney::Source::Yarn.new(yarn_lock: File.read('spec/fixtures/test_project/yarn.lock'))
      dependencies = yarn.dependencies

      expect(dependencies.count).to eq 3
      expect(dependencies[0]).to  have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'abbrev', version: '1.1.1')
      expect(dependencies[1]).to  have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'accepts', version: '1.3.4')
      expect(dependencies[2]).to  have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'accepts', version: '1.3.5')
    end
  end

end
