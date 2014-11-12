module Deployment
  class DeploymentRunner

    def initialize(stack_name)
      @timestamp = Time.now.to_i
      @stack_name = "marsbook-deployment-#{@timestamp}"
    end

    def package(artifact_name)
      puts "Zipping up application..."
      `zip #{artifact_name} * -x Rakefile LICENSE deployment.template README.md .gitignore .travis.yml`
      raise "Failed to zip archive" unless $?.success?
      artifact_name
    end

    def upload(bucket_name, artifact_name)
      split = artifact_name.split(".")
      remote_file_name = "#{split[0]}-#{@timestamp}.#{split[1]}"

      s3 = AWS::S3.new

      puts "Bucket '#{bucket_name}' does not appear to exist... Creating..." unless s3.buckets[@bucket_name].exists?
      s3.buckets.create(bucket_name) unless s3.buckets[bucket_name].exists?

      puts "Uploading file #{artifact_name} to bucket '#{bucket_name}'..."
      s3.buckets[bucket_name].objects[remote_file_name].write(:file => artifact_name)
      remote_file_name
    end

    def deploy(template, bucket_name, remote_artifact_name, db_name, db_user, db_password)
      puts "Deploying cloudformation stack"
      cfm = AWS::CloudFormation.new
      template_str = IO.read(template)

      wait_for cfm.stacks.create(@stack_name, template_str, :parameters => {
          "artifactBucketName" => bucket_name,
          "artifactName" => remote_artifact_name,
          "databaseName" => db_name,
          "databasePort" => "3306",
          "databaseUsername" => db_user,
          "databasePassword" => db_password
      })
    end

    private

    def wait_for(stack)
      puts "Waiting for deployment..."
      sleep 10

      while (stack.status == "CREATE_IN_PROGRESS" || stack.status == "UPDATE_IN_PROGRESS")
        puts "Still deploying.... Will retry in 10 seconds..."
        sleep 10
      end

      raise "Failed to reach a successful deployment status..." if (stack.status != "CREATE_COMPLETE" || stack.status != "UPDATE_COMPLETE")
      stack
    end
  end
end