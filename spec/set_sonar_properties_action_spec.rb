describe Fastlane::Actions::SetSonarPropertiesAction do
  describe 'Run with wrong input' do
    it 'raises error if params are missing' do
      expect do
        Fastlane::Actions::SetSonarPropertiesAction.run(nil)
      end.to raise_exception(RuntimeError, /Missing params/)
    end
    it 'raises error if given file is missing' do
      params = {
        :input_path => "no_file"
      }
      build_params(params)

      expect do
        Fastlane::Actions::SetSonarPropertiesAction.run(params)
      end.to raise_exception(RuntimeError, /Sonar properties file not found for path: no_file/)
    end
  end
  describe 'Run with correct files' do
    it 'works as expected for props object' do
      params = {}
      params[:input_path] = "spec/fixtures/sonar-project.properties"
      params[:output_path] = "spec/fixtures/sonar-project-res.properties"
      params[:sonar_props] = {
        "sonar.host.url" => "https://github.com/",
        "sonar.projectName" => "Dummy project",
        "sonar.projectVersion" => "1.1"
      }
      build_params(params)
      res = Fastlane::Actions::SetSonarPropertiesAction.run(params)
      expect(res).to eq({
        "sonar.host.url" => "https://github.com/",
        "sonar.projectKey" => "dummy-project",
        "sonar.projectName" => "Dummy project",
        "sonar.projectVersion" => "1.1"
      })
    end
    it 'works as expected for props string' do
      params = {}
      params[:input_path] = "spec/fixtures/sonar-project.properties"
      params[:output_path] = "spec/fixtures/sonar-project-res.properties"
      params[:sonar_props] = "sonar.host.url=https://github.com/,sonar.projectName=Dummy project,sonar.projectVersion=1.1"
      build_params(params)
      res = Fastlane::Actions::SetSonarPropertiesAction.run(params)
      expect(res).to eq({
        "sonar.host.url" => "https://github.com/",
        "sonar.projectKey" => "dummy-project",
        "sonar.projectName" => "Dummy project",
        "sonar.projectVersion" => "1.1"
      })
    end
  end

  def build_params(needed_params = {})
    available_options = Fastlane::Actions::SetSonarPropertiesAction.available_options
    @params = FastlaneCore::Configuration.create(available_options, needed_params)
  end
end
