describe Gurney::Config do

  describe 'from_file' do
    it 'loads values from a yaml config file' do
      config = Gurney::Config.from_yaml(File.read('spec/fixtures/test_project/gurney.yml'))
      expect(config.api_token).to eq '1234567890'
      expect(config.project_id).to eq '1'
      expect(config.branches).to contain_exactly 'master', 'main', 'production'
      expect(config.api_url).to eq 'http://example.com/project/<project_id>/branch/<branch>'
      expect(config.prefix).to eq '.'
    end
  end

end
