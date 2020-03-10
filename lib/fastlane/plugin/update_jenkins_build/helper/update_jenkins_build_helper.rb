require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class UpdateJenkinsBuildHelper

      def self.jenkins_version(url, user, password)
        url = "#{url}/api/json"
        res = if user && password
                HTTP.basic_auth(user: user, pass: password)
                    .get(url)
              else
                HTTP.get(url)
              end

        res.headers['X-Jenkins']
      end
    end
  end
end
