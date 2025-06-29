describe Gurney::CLI do

  describe '.run' do
    let(:main_branch) { 'master' }

    def expect_report(to: 'http://example.com/project/1/branch/master')
      expect_any_instance_of(Gurney::Api).to receive(:post_json).with(to, anything).and_return(double)
    end

    def run_with_branch_info(branch_info, mode: '--hook', debug: false)
      with_stdin(branch_info) do
        if debug
          Gurney::CLI.run([mode])
        else
          silent { Gurney::CLI.run([mode]) }
        end
      end
    end

    context 'when the dependency files are on top level' do
      include_context 'within a temporary git repository', path: 'spec/fixtures/test_project'

      it 'queries the correct url' do
        expect_report to: 'http://example.com/project/1/branch/master'
        silent { Gurney::CLI.run }
      end

      it 'reports all dependencies to the API' do
        expect_any_instance_of(Gurney::Api).to receive(:post_dependencies)
          .with(
            dependencies: contain_exactly(
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
            ),
            branch: 'master',
            project_id: '1',
            repo_path: instance_of(String),
          ).and_return(double)
        silent { Gurney::CLI.run }
      end

      it 'prints a success message to stdout' do
        expect_report
        expect { Gurney::CLI.run }.to output("Gurney: reported dependencies (npm: 10, rubygems: 5, ruby: 1)\n").to_stdout
      end

      it 'overwrites options from the config with command line parameter' do
        expect_report to: 'http://test.example.com/project/2/branch/master'
        silent { Gurney::CLI.run(%w[-c incomplete_config.yml --project-id 2 --api-url http://test.example.com/project/<project_id>/branch/<branch>]) }
      end

      it 'can run as a client-side pre-push hook' do
        expect_report
        run_with_branch_info 'refs/heads/master 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/master 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
          mode: '--client-hook'
      end

      describe '(remote post-receive hook mode)' do
        before do
          allow(ENV).to receive(:[]).and_call_original
          allow(ENV).to receive(:[]).with("GIT_DIR").and_return(".git")
        end

        it 'works' do
          expect_report
          run_with_branch_info '123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/master'
        end

        it 'works when GIT_DIR is not set (issue with GitLab)' do
          allow(ENV).to receive(:[]).with("GIT_DIR").and_return(nil)
          allow(Dir).to receive(:pwd).and_return(".git")

          expect_report
          run_with_branch_info '123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/master'
        end

        # Ambulance will complain if that ever changes. This is to prevent Gurney
        # reporting to the wrong project after a project fork.
        it 'sends the repository path along' do
          expect_any_instance_of(Gurney::Api)
            .to receive(:post_dependencies)
              .with(hash_including(dependencies: instance_of(Array), repo_path: %r{spec/fixtures/test_project/.git$}))
              .and_return(double)
          run_with_branch_info '123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/master'
        end

        it 'does not crash on utf8 chars in branch names' do
          with_stdin('refs/heads/ö 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/ö 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa') do
            expect { Gurney::CLI.run('--client-hook'.split(' ')) }.not_to raise_error
          end
        end

        it 'does not crash when receiving tags (BUGFIX)' do
          expect_any_instance_of(Gurney::Api).not_to receive(:post_json)
          run_with_branch_info '123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/tags/v1'
        end

        context 'with main branch named "main"' do
          let(:main_branch) { 'main' }

          it 'works' do
            expect_report(to: 'http://example.com/project/1/branch/main')
            run_with_branch_info '123abcdefaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa 123abcaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/heads/main'
          end
        end
      end
    end

    context 'when the dependency files are nested in a subdirectory' do
      include_context 'within a temporary git repository', path: 'spec/fixtures'

      it 'reports all dependencies to the API' do
        expect_any_instance_of(Gurney::Api).to receive(:post_dependencies)
          .with(
            dependencies: contain_exactly(
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
            ),
            branch: 'master',
            project_id: '1',
            repo_path: instance_of(String),
          ).and_return(double)

        silent { Gurney::CLI.run(%w[--config test_project/gurney.yml --prefix test_project]) }
      end
    end

  end

end
