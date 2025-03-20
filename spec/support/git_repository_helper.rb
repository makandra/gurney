# Create a temporary Git repository within the fixtures to avoid committing it into the main repository
shared_context 'within a temporary git repository' do
  let(:main_branch) { 'master' }

  around(:example) do |example|
    Dir.chdir('spec/fixtures/test_project') do
      git = Git.init('.', initial_branch: main_branch)
      git.add(all: true)
      git.commit('init commit')
      begin
        example.run
      ensure
        FileUtils.rm_rf('.git')
      end
    end
  end
end
