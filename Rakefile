require "bundler/gem_tasks"
require "bundler/setup"
require "bundler"
require "aws-sdk"
require "rake"

Bundler.setup(:default, :test, :deploy)

desc "Run the default which is to run the tests"
task :default => :test

# desc "Run the specs"
# RSpec::Core::RakeTask.new(:test) do |t|
#   t.pattern = ['**/spec/**/*_spec.rb']
# end

desc "Update the gem version by one value"
task :update_version, :new_version do |t, args|
  abort("No version specified") if not args[:new_version]

  VERSION = /VERSION\s=\s\"(?<major>\d*)\.(?<minor>\d*)\.(?<build>\d*)\"/
  puts "Updating application to build #{args[:new_version]}"

  version_file = File.dirname(__FILE__) + "/lib/blueprint-deploy/version.rb"
  version_contents = File.read(version_file)

  match = VERSION.match(version_contents)
  return if not match

  new_version = "#{match[:major]}.#{match[:minor]}.#{args[:new_version]}"
  puts "Updating the version to #{new_version}"

  replace = "VERSION = \"#{new_version}\""
  new_contents = version_contents.gsub(VERSION, replace)

  File.open(version_file, 'w') do |data|
    data << new_contents
  end
end

desc "Deploy to beanstalk"
task :deploy do
  puts "Zipping up application..."
  #`zip app.zip * -x Rakefile LICENSE deployment.template README.md .gitignore .travis.yml`
  `zip -r app.zip .`
  abort "Failed to zip archive" unless $?.success?

  abort "Missing environment variable 'S3_BUCKET_NAME'" unless ENV["S3_BUCKET_NAME"]
  bucket_name = ENV["S3_BUCKET_NAME"]

  abort "Missing environment variable 'RDS_DATABASENAME'" unless ENV['RDS_DATABASENAME']
  database_name = ENV['RDS_DATABASENAME']

  abort "Missing environment variable 'RDS_USERNAME'" unless ENV['RDS_USERNAME']
  database_username = ENV["RDS_USERNAME"]

  abort "Missing environment variable 'RDS_PASSWORD'" unless ENV['RDS_PASSWORD']
  database_password = ENV["RDS_PASSWORD"]

  file_name = "app.zip"
  timestamp = Time.now.to_i
  remote_file_name = "app-#{timestamp}.zip"

  s3 = AWS::S3.new
  cfm = AWS::CloudFormation.new

  puts "Bucket '#{bucket_name}' does not appear to exist... Creating..." unless s3.buckets[bucket_name].exists?
  s3.buckets.create(bucket_name) unless s3.buckets[bucket_name].exists?

  puts "Uploading file #{file_name} to bucket '#{bucket_name}'..."
  s3.buckets[bucket_name].objects[remote_file_name].write(:file => file_name)

  puts "Deploying cloudformation stack"

  template = IO.read("deployment.template")

  stack = cfm.stacks.create("marsbook-deployment-#{timestamp}", template, :parameters => {
      "artifactBucketName" => bucket_name,
      "artifactName" => remote_file_name,
      "databaseName" => database_name,
      "databasePort" => "3306",
      "databaseUsername" => database_username,
      "databasePassword" => database_password
  })

  puts "Waiting for deployment..."
  sleep 10

  while (stack.status == "CREATE_IN_PROGRESS" || stack.status == "UPDATE_IN_PROGRESS")
    puts "Still deploying.... Will retry in 10 seconds..."
    sleep 10
  end

  abort "Failed to reach a successful deployment status..." if (stack.status != "CREATE_COMPLETE" || stack.status != "UPDATE_COMPLETE")
end