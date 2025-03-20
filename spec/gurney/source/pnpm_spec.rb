describe Gurney::Source::Pnpm do
  describe 'dependencies' do
    it 'returns an array with all dependencies from pnpm-lock.yaml with lockfileVersion 9' do
      pnpm = Gurney::Source::Pnpm.new(pnpm_lock: File.read('spec/fixtures/test_project/pnpm-lock.yaml'))
      dependencies = pnpm.dependencies

      expect(dependencies.count).to eq 4
      expect(dependencies[0]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: '@fortawesome/fontawesome-free', version: '5.15.4')
      expect(dependencies[1]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'bootstrap', version: '4.6.2')
      expect(dependencies[2]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'jquery', version: '3.7.1')
      expect(dependencies[3]).to have_attributes(class: Gurney::Dependency, ecosystem: 'npm', name: 'popper.js', version: '1.16.1')
    end

    it 'prints a warning and returns an empty array for incompatible lockfile versions' do
      pnpm = Gurney::Source::Pnpm.new(pnpm_lock: File.read('spec/fixtures/lockfiles/pnpm_lock_v6.yaml'))
      expect { pnpm.dependencies }.to output(/pnpm-lock.yaml: Lockfile version 6 is unsupported. No npm dependencies reported./).to_stdout
      expect(pnpm.dependencies).to eq []
    end

    it 'handles invalid YAML gracefully' do
      pnpm = Gurney::Source::Pnpm.new(pnpm_lock: ': invalid: yaml:')
      expect { pnpm.dependencies }.to raise_error(Gurney::Error, /Invalid pnpm-lock.yaml format/)
    end
  end
end 
