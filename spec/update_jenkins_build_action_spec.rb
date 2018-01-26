describe Fastlane::Actions::UpdateJenkinsBuildAction do
  describe '#run' do
    let(:stub_ci_url) { 'http://stub.ci.com/' }
    let(:stub_project_name) { 'example-project' }
    let(:stub_build_number) { '10' }

    let(:stub_auth_user) { 'user' }
    let(:stub_auth_token_or_password) { 'token_or_password' }

    before do
      ENV['JENKINS_URL'] = stub_ci_url
      ENV['JOB_NAME'] = stub_project_name
      ENV['BUILD_NUMBER'] = stub_build_number
    end

    describe 'use current build of project' do
      context 'with auth' do
        it "should update description and return true" do
          description = 'hello world'
          stub_jenkins_project(stub_project_name, stub_build_number, description, 'foo', 'bar')

          r = Fastlane::FastFile.new.parse("lane :test do
            update_jenkins_build(description: '#{description}', user: 'foo', password: 'bar')
          end").runner.execute(:test)

          expect(r).to be true
        end
      end

      context 'without auth' do
        it "should update description and return true" do
          description = 'hello world'
          stub_jenkins_project(stub_project_name, stub_build_number, description)

          r = Fastlane::FastFile.new.parse("lane :test do
            update_jenkins_build(description: '#{description}')
          end").runner.execute(:test)

          expect(r).to be true
        end
      end
    end

    describe 'use custom build of project' do
      let(:project_name) { 'foobar' }
      let(:build_number) { 1234 }
      let(:description) { 'hello world' }

      context 'with auth' do
        it "should update description and return true" do
          stub_jenkins_project(project_name, build_number, description, 'foo', 'bar')

          r = Fastlane::FastFile.new.parse("lane :test do
            update_jenkins_build(
              project: '#{project_name}',
              build_number: '#{build_number}',
              description: '#{description}',
              user: 'foo',
              password: 'bar'
            )
          end").runner.execute(:test)

          expect(r).to be true
        end
      end

      context 'without auth' do
        it "should update description and return true" do
          stub_jenkins_project(project_name, build_number, description)

          r = Fastlane::FastFile.new.parse("lane :test do
            update_jenkins_build(project: '#{project_name}', build_number: '#{build_number}', description: '#{description}')
          end").runner.execute(:test)

          expect(r).to be true
        end
      end
    end

    describe 'use not exists build of project' do
      let(:project_name) { 'fake' }
      let(:build_number) { 404 }
      let(:description) { 'hello world' }

      context 'with auth' do
        it "return false" do
          stub_jenkins_project(project_name, build_number, description, 'foo', 'bar', 404)

          r = Fastlane::FastFile.new.parse("lane :test do
            update_jenkins_build(
              project: '#{project_name}',
              build_number: #{build_number},
              description: '#{description}',
              user: 'foo',
              password: 'bar'
            )
          end").runner.execute(:test)

          expect(r).to be false
        end
      end

      context 'without auth' do
        it "return false" do
          stub_jenkins_project(project_name, build_number, description, nil, nil, 404)

          r = Fastlane::FastFile.new.parse("lane :test do
            update_jenkins_build(project: '#{project_name}', build_number: '#{build_number}', description: '#{description}')
          end").runner.execute(:test)

          expect(r).to be false
        end
      end
    end
  end
end
