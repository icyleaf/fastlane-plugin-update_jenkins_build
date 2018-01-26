$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'webmock/rspec'
require 'simplecov'

# SimpleCov.minimum_coverage 95
SimpleCov.start

# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require 'fastlane' # to import the Action super class
require 'fastlane/plugin/update_jenkins_build' # import the actual plugin

Fastlane.load_actions # load other actions (in case your plugin calls other actions or shared values)

def stub_jenkins_project(name, build, description, user = nil, password = nil, status = 302)
  template_url = Addressable::Template.new("#{ENV['JENKINS_URL']}job/#{name}/#{build}/submitDescription")

  mock = stub_request(:post, template_url).with(body: { description: description })
  if user && password
    mock = mock.with(basic_token_header(user, password))
  end

  mock.to_return(
    status: status,
    headers: { 'Content-Type' => 'text/html;charset=UTF-8' },
    body: '<!DOCTYPE html>'
  )
end

def basic_token_header(user, password)
  token_encode = Base64.encode64("#{user}:#{password}").strip
  { headers: { 'Authorization' => "Basic #{token_encode}" } }
end
