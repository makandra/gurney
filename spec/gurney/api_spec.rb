describe Gurney::Api do

  describe 'post_dependencies' do
    it 'replaces tokens in the base url' do
      api = Gurney::Api.new(base_url: 'http://example.com/projects/<project_id>/branches/<branch>', token: '')
      expect(api).to receive(:post_json).with('http://example.com/projects/1/branches/master', anything).and_return(double)
      api.post_dependencies(dependencies: [], branch: 'master', project_id: '1')
    end
  end

end
