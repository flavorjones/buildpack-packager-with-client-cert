
task default: :test

task test: ["nginx:test", "buildpack:package"]

namespace :nginx do
  desc "Start up the docker image running nginx"
  task :start do
    system %Q{docker run -v $(pwd):/nginx -p 4443:443 -it cloudfoundry/cflinuxfs2 /nginx/bootstrap-docker.sh}
  end

  desc "Verify that the nginx server is properly checking client certificates."
  task :test do
    system %Q{./test-client-cert.sh}
  end

end

def find_cached_artifact
  Dir[File.join(ENV['HOME'], ".buildpack-packager", "cache", "*4443*index.html*")].first
end

namespace :buildpack do
  BUILDPACK_NAME = "foo_buildpack-cached-v1.0.zip"
  desc "Package a buildpack, pulling artifact from authenticated server."
  task :package do
    FileUtils.rm_rf BUILDPACK_NAME
    cached_file = find_cached_artifact
    if cached_file
      puts "deleting cached file #{cached_file}"
      FileUtils.rm(*cached_file)
    end

    system %Q{bundle exec buildpack-packager --cached --force-download > /dev/null 2>&1}
    raise "setup isn't right" if File.exist?(BUILDPACK_NAME)

    system %Q{CURL_HOME=$(pwd) bundle exec buildpack-packager --cached --force-download}
    raise "could not build the buildpack" unless File.exist?(BUILDPACK_NAME)
    puts "#"
    puts "#  SUCCESS."
    puts "#"
  end
end
