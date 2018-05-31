namespace :acceptance do
  ARTIFACT_DIR = File.join('acceptance', 'artifacts')
  TEST_BOXES = {
    'centos-virtualbox.box' => 'https://s3.amazonaws.com/puppetlabs-vagrantcloud/centos-7.2-x86_64-virtualbox-nocm-1.0.1.box',
  }

  directory ARTIFACT_DIR
  TEST_BOXES.each do |box, box_url|
    file File.join(ARTIFACT_DIR, box) => ARTIFACT_DIR do |path|
      puts 'Downloading: ' + box_url
      Kernel.system 'curl', '-L', '-o', path.to_s, box_url
    end
  end

  desc 'downloads test boxes and other artifacts'
  task :setup => TEST_BOXES.map {|box, _| File.join(ARTIFACT_DIR, box)}


  desc 'runs acceptance tests'
  task :run => :setup do
    command = 'vagrant-spec test'
    puts command
    puts
    exec(command)
  end
end
