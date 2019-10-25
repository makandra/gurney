describe Gurney::CLI do
  describe 'run' do

    # create a temporary git repository within the fixtures to avoid committing it into the main repository
    around :example do |example|
      Dir.chdir('spec/fixtures/test_project') do
        g = Git.init
        g.add(:all=>true)
        g.commit 'init commit'
        begin
          example.run
        ensure
          FileUtils.rm_rf '.git'
        end
      end
    end

    it 'does query the correct url' do
      expect_any_instance_of(Gurney::Api).to receive(:post_json).with('http://example.com/project/1/branch/master', anything).and_return(double)
      Gurney::CLI.run
    end

    it 'does report all dependencies to the api' do
      expect_any_instance_of(Gurney::Api).to receive(:post_dependencies)
        .with(dependencies: contain_exactly(
            Gurney::Dependency.new(ecosystem: 'rubygems', name: 'byebug', version: '11.0.1'),
            Gurney::Dependency.new(ecosystem: 'rubygems', name: 'httparty', version: '0.17.1'),
            Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types', version: '3.3'),
            Gurney::Dependency.new(ecosystem: 'rubygems', name: 'mime-types-data', version: '3.2019.1009'),
            Gurney::Dependency.new(ecosystem: 'rubygems', name: 'multi_xml', version: '0.6.0'),
            Gurney::Dependency.new(ecosystem: 'npm', name: 'abbrev', version: '1.1.1'),
            Gurney::Dependency.new(ecosystem: 'npm', name: 'accepts', version: '1.3.4'),
            Gurney::Dependency.new(ecosystem: 'npm', name: 'accepts', version: '1.3.5'),
          ),
          branch: 'master',
          project_id: '1').and_return(double)
      Gurney::CLI.run
    end

  end
end
