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
      silent { Gurney::CLI.run }
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
            Gurney::Dependency.new(ecosystem: 'ruby', name: 'ruby', version: '2.3.8'),
          ),
          branch: 'master',
          project_id: '1').and_return(double)
      silent { Gurney::CLI.run }
    end

    it 'prints success message to stdout' do
      expect_any_instance_of(Gurney::Api).to receive(:post_json).with(anything, anything).and_return(double)
      expect { Gurney::CLI.run }.to output("Gurney: reported dependencies (npm: 3, rubygems: 5, ruby: 1)\n").to_stdout
    end

    it 'overwrites options from the config with command line parameter' do
      expect_any_instance_of(Gurney::Api).to receive(:post_json).with('http://test.example.com/project/2/branch/master', anything).and_return(double)
      silent { Gurney::CLI.run('-c incomplete_config.yml --project-id 2 --api-url http://test.example.com/project/<project_id>/branch/<branch>'.split(' ')) }
    end

    it 'does work as a hook' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GIT_DIR").and_return(".git")
      expect_any_instance_of(Gurney::Api).to receive(:post_json).with('http://example.com/project/1/branch/master', anything).and_return(double)

      with_stdin('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/master') do
       silent { Gurney::CLI.run('--hook'.split(' ')) }
      end
    end

    it 'does work as a client-side hook' do
      expect_any_instance_of(Gurney::Api).to receive(:post_json).with('http://example.com/project/1/branch/master', anything).and_return(double)

      with_stdin('refs/heads/master aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/master aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') do
       silent { Gurney::CLI.run('--client-hook'.split(' ')) }
      end
    end

    it 'does not crash when receiving tags (BUGFIX)' do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with("GIT_DIR").and_return(".git")
      expect_any_instance_of(Gurney::Api).not_to receive(:post_json)

      with_stdin('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/tags/v1') do
       silent { Gurney::CLI.run('--hook'.split(' ')) }
      end
    end

  end
end
