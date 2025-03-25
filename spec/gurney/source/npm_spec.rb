describe Gurney::Source::Npm do
  describe 'dependencies' do
    it 'returns an array with all dependencies from package-lock.json' do
      npm = Gurney::Source::Npm.new(package_lock_json: File.read('spec/fixtures/test_project/package-lock.json'))
      dependencies = npm.dependencies

      expect(dependencies.count).to eq 3
      expect(dependencies[0]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'chalk', version: '5.4.1')
      expect(dependencies[1]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'commander', version: '13.1.0')
      expect(dependencies[2]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'lodash', version: '4.17.21')
    end

    it 'prints a warning and returns an empty array for incompatible lockfile versions' do
      npm = Gurney::Source::Npm.new(package_lock_json: File.read('spec/fixtures/lockfiles/package_lock_v1.json'))
      expect { npm.dependencies }.to output(/package-lock.json: Lockfile version 1 is unsupported. No npm dependencies reported./).to_stdout
      expect(npm.dependencies).to eq []
    end

    it 'throws an error, if the package-lock.json is invalid' do
      npm = Gurney::Source::Npm.new(package_lock_json: '{invalid json}')
      expect { npm.dependencies }.to raise_error(Gurney::Error, /Invalid package-lock.json format/)
    end
  end
end
