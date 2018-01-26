require 'fastlane/action'
require_relative '../helper/update_jenkins_build_helper'
require 'http'
require 'uri'

module Fastlane
  module Actions
    class UpdateJenkinsBuildAction < Action
      def self.run(params)
        @user = params[:user]
        @password = params[:password]
        @project = params[:project]
        @build_number = params[:build_number]
        @description = params[:description]

        url = "#{base_uri}/submitDescription"
        res = if @user
                HTTP.basic_auth(user: @user, pass: @password)
                    .post(url, form: {description: @description})
              else
                HTTP.post(url, form: {description: @description})
              end

        result = res.status == 200 ? true : false

        params = {
          title: "Summary for update_jenkins_build #{UpdateJenkinsBuild::VERSION}".green,
          rows: {
            result: (result ? 'success' : 'fail'),
            url: "#{base_uri}/editDescription",
            auth: @user ? true : false,
            description: @description,
          }
        }

        puts ""
        puts Terminal::Table.new(params)
        puts ""

        result
      end

      def self.base_uri
        uri = URI(ENV['JENKINS_URL'])
        uri.path = "/job/#{@project}/#{@build_number}"
        uri.to_s
      end

      def self.return_value
        "ture/false"
      end

      def self.return_type
        :boolean
      end

      def self.example_code
        [
          'update_jenkins_build(
            description: "AdHoc v1.0 (1.0.1)"
          )',
          'update_jenkins_build(
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

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :description,
                                  env_name: "UPDATE_JENKINS_BUILD_DESCRIPTION",
                               description: "the description of current build",
                                  optional: false,
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
