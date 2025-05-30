describe Gurney::DependencyCollector do
  let(:git_file_reader) { Gurney::GitFileReader.new(git, 'master', read_from_git: false)}
  let(:collector) { described_class.new(git_file_reader) }
  let(:git) { @g }

  describe '#collect_all' do
    let(:main_branch) { 'master' }

    include_context 'within a temporary git repository', path: 'spec/fixtures/test_project'

    it 'collects all dependencies, including npm dependencies from different lock files' do
      dependencies = collector.collect_all
      expect(dependencies).to contain_exactly(
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'byebug', version: '11.0.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'httparty', version: '0.17.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types', version: '3.3'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types-data', version: '3.2019.1009'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'multi_xml', version: '0.6.0'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'abbrev', version: '1.1.1'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'accepts', version: '1.3.4'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'accepts', version: '1.3.5'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'chalk', version: '5.4.1'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'commander', version: '13.1.0'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'lodash', version: '4.17.21'),
        Gurney::Dependency.new(ecosystem: 'npm', name: '@fortawesome/fontawesome-free', version: '5.15.4'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'bootstrap', version: '4.6.2'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'jquery', version: '3.7.1'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'popper.js', version: '1.16.1'),
        Gurney::Dependency.new(ecosystem: 'ruby', name: 'ruby', version: '2.3.8'),
      )
    end

    it 'collects npm dependencies from package-lock.json and pnpm-lock.yaml, if yarn.lock is missing' do
      expect(collector).to receive(:yarn_lock).and_return(nil)

      dependencies = collector.collect_all
      expect(dependencies).to contain_exactly(
        Gurney::Dependency.new(ecosystem: 'npm', name: 'chalk', version: '5.4.1'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'commander', version: '13.1.0'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'lodash', version: '4.17.21'),
        Gurney::Dependency.new(ecosystem: 'npm', name: '@fortawesome/fontawesome-free', version: '5.15.4'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'bootstrap', version: '4.6.2'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'jquery', version: '3.7.1'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'popper.js', version: '1.16.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'byebug', version: '11.0.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'httparty', version: '0.17.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types', version: '3.3'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types-data', version: '3.2019.1009'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'multi_xml', version: '0.6.0'),
        Gurney::Dependency.new(ecosystem: 'ruby', name: 'ruby', version: '2.3.8'),
      )
    end

    it 'collects npm dependencies from pnpm-lock.json, if yarn.lock and package-lock.json is missing' do
      expect(collector).to receive(:yarn_lock).and_return(nil)
      expect(collector).to receive(:package_lock_json).and_return(nil)

      dependencies = collector.collect_all
      expect(dependencies).to contain_exactly(
        Gurney::Dependency.new(ecosystem: 'npm', name: '@fortawesome/fontawesome-free', version: '5.15.4'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'bootstrap', version: '4.6.2'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'jquery', version: '3.7.1'),
        Gurney::Dependency.new(ecosystem: 'npm', name: 'popper.js', version: '1.16.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'byebug', version: '11.0.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'httparty', version: '0.17.1'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types', version: '3.3'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types-data', version: '3.2019.1009'),
        Gurney::Dependency.new(ecosystem: 'rubygems', name: 'multi_xml', version: '0.6.0'),
        Gurney::Dependency.new(ecosystem: 'ruby', name: 'ruby', version: '2.3.8'),
      )
    end
  end
end
