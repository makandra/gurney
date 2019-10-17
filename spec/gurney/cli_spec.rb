describe Gurney::CLI do
  describe 'run' do

    it 'does not smoke' do
      Dir.chdir('spec/fixtures') do
        expect_any_instance_of(Gurney::Api).to receive(:post_dependencies).with(anything).and_return(double)
        Gurney::CLI.run
      end
    end

  end
end
