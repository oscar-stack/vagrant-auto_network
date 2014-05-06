namespace :acceptance do
  ARTIFACT_DIR = File.join('acceptance', 'artifacts')
  TEST_BOXES = %w[
    https://vagrantcloud.com/puppetlabs/centos-6.5-64-nocm/version/2/provider/virtualbox.box
  ]

  directory ARTIFACT_DIR
  TEST_BOXES.each do |box_url|
    file File.join(ARTIFACT_DIR, File.basename(box_url)) => ARTIFACT_DIR do |path|
      puts 'Downloading: ' + box_url
      Kernel.system 'curl', '-L', '-o', path.to_s, box_url
    end
  end

  desc 'downloads test boxes and other artifacts'
  task :setup => TEST_BOXES.map {|box_url| File.join(ARTIFACT_DIR, File.basename(box_url))}

  desc 'runs acceptance tests'
  task :run => :setup do
    command = 'vagrant-spec test'
    puts command
    puts
    exec(command)
  end
end
