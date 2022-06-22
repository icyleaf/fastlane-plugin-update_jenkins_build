require 'fastlane/action'
require_relative '../helper/update_jenkins_build_helper'
require 'rubygems'
require 'http'
require 'uri'

module Fastlane
  module Actions
    class UpdateJenkinsBuildAction < Action
      def self.run(params)
        @user = params[:user]
        @password = params[:password]
        @url = params[:url]
        @project = params[:project]
        @build_number = params[:build_number]
        @description = format_description(params[:description])

        url = "#{base_uri}/submitDescription"
        res = if @user || @password
                HTTP.basic_auth(user: @user, pass: @password)
                    .post(url, form: {description: @description})
              else
                HTTP.post(url, form: {
                  "description" => @description,
                  "Jenkins-Crumb" => "234234234234234234" # random value
                })
              end

        # Submit form succesed it will 302 to the build url.
        result = res.code == 302 ? 'success' : "#{res.code} fail"

        jenkins_version = Helper::UpdateJenkinsBuildHelper.jenkins_version(@url, @user, @password)
        params = {
          title: "Summary for update_jenkins_build #{UpdateJenkinsBuild::VERSION}".green,
          rows: {
            jenkins_version: jenkins_version,
            result: result,
            url: "#{base_uri}/editDescription",
            auth: @user ? true : false,
            description: @description,
          }
        }

        puts Terminal::Table.new(params)

        if res.code != 302
          UI.error "Detect `update_jenkins_build` ran fail."
          if jenkins_version && Gem::Version.new(jenkins_version) > Gem::Version.new('2.221')
            UI.error "Because Jenkins v#{jenkins_version} removed 'disable CSRF Protection' option since 2.222,"
            UI.error "You need append '-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true' into Jenkins startup argument."
            UI.error "Please check https://github.com/icyleaf/fastlane-plugin-update_jenkins_build/issues/2"
          else
            UI.error "Please 'disable CSRF Protection' in 'Global Security Settings' page from Jenkins."
          end
        end

        [result, res.body]
      end

      def self.format_description(descripion)
        descripion.gsub('\n', "\n")
      end

      def self.base_uri
        uri = URI(@url)
        uri.path = "/job/#{@project}/#{@build_number}"
        uri.to_s
      end

      def self.return_value
        "[ture/false, response_body]"
      end

      def self.return_type
        :array
      end

      def self.example_code
        [
          'update_jenkins_build(
            description: "AdHoc v1.0 (1.0.1)"
          )',
          'update_jenkins_build(
            url: "http://127.0.0.1:8080/", # specify specific jenkins url
            project: "foobar", # specify specific project name
            build_number: 75, # specify specific build number
            description: "AdHoc v1.0 (1.0.1)",
            user: "admin",
            password: "123"
          )',
          'result = update_jenkins_build(
            description: "AdHoc v1.0 (1.0.1)"
          )'
        ]
      end

      def self.description
        "Update build's description of jenkins"
      end

      def self.details
        "MUST disable CSRF in Security configure"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :description,
                                  env_name: "UPDATE_JENKINS_BUILD_DESCRIPTION",
                               description: "the description of current build",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :url,
                                  env_name: "UPDATE_JENKINS_BUILD_URL",
                               description: "the url of jenkins",
                             default_value: ENV['JENKINS_URL'],
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :project,
                                  env_name: "UPDATE_JENKINS_BUILD_PROJECT",
                               description: "the name of project(job)",
                             default_value: ENV["JOB_NAME"],
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :build_number,
                                  env_name: "UPDATE_JENKINS_BUILD_BUILD_NUMBER",
                               description: "the build number of project(job)",
                             default_value: ENV["BUILD_NUMBER"],
                                  optional: true,
                                      type: Integer),
          FastlaneCore::ConfigItem.new(key: :user,
                                  env_name: "UPDATE_JENKINS_BUILD_USER",
                               description: "the user of jenkins if enabled security",
                             default_value: ENV["CICL_CHANGELOG_JENKINS_USER"],
                                  optional: true,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :password,
                                  env_name: "UPDATE_JENKINS_BUILD_PASSWORD",
                               description: "the password of jenkins if enabled security",
                             default_value: ENV["CICL_CHANGELOG_JENKINS_TOKEN"],
                                  optional: true,
                                      type: String),
        ]
      end

      def self.authors
        ["icyleaf"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
