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

    it 'does not smoke' do
      expect_any_instance_of(Gurney::Api).to receive(:post_dependencies).with(anything).and_return(double)
      Gurney::CLI.run
    end

  end
end
