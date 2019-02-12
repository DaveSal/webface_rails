class WebfaceGenerator < Rails::Generators::Base

  source_root File.expand_path('templates', __dir__)

  def add_webface
    # We'll later change this to fetching webface.js as a node_module, but not now.
    gitmodules = File.readlines("#{Rails.root}/.gitmodules")
    unless gitmodules.join("\n").include?("webface.js.git")
      `git submodule add git@gitlab.com:hodl/webface.js.git`
    end
    gitmodules.each do |line|
      if line.include?("webface") && line.include?("path =")
        @webface_path = line.strip.sub(/\Apath = /, "")
      end
    end
    puts "Webface path is #{@webface_path}"
  end

  def create_webface_unit_test_dir
    `mkdir -p #{Rails.root}/spec/webface/`
    `mkdir -p #{Rails.root}/spec/webface/components/`
  end

  def copy_unit_test_server
    copy_file "webface_test_server.js", "spec/webface/test_server"
    copy_file "run_webface_test", "spec/webface/run_test"
    copy_file "mocha.css", "spec/webface/mocha.css"
    copy_file "mocha.pug", "spec/webface/mocha.pug"
    copy_file "test_utils.js", "spec/webface/test_utils.js"
    copy_file "webface.test.js", "spec/webface/webface.test.js"
    copy_file "webface_init.js", "spec/webface/webface_init.js"
    copy_file "test_animator.js", "spec/webface/test_animator.js"
    copy_file "my_component.test.js", "spec/webface/components/my_component.test.js"
  end

  def add_node_modules_to_gitignore
    `echo "spec/webface/node_modules"           >> #{Rails.root}/.gitignore` unless File.read("#{Rails.root}/.gitignore").include?("spec/webface/node_modules")
    `echo "app/assets/javascripts/node_modules" >> #{Rails.root}/.gitignore` unless File.read("#{Rails.root}/.gitignore").include?("app/assets/javascripts/node_modules")
  end

  def symlink_javascripts_dir
    # Create symlink to the app/assets/javascripts dir
    files = "#{Rails.root}/app/assets/javascripts #{Rails.root}/spec/webface/source"
    unless File.exists?("#{Rails.root}/spec/webface/source")
      puts "   Symlinking ".colorize(:green) + files
      `ln -s #{files}`
    else
      puts "   Symlink already exists ".colorize(:light_blue) + files
    end
  end

  def copy_package_json
    files = "#{Rails.root}/#{@webface_path}/package.json #{Rails.root}/app/assets/javascripts/"
    unless File.exists?("#{Rails.root}/app/assets/javascripts/package.json")
      puts "   Copying ".colorize(:green) + files
      `cp #{files}`.colorize(:green)
    else
      puts "   File to be copied already exists ".colorize(:light_blue) + files
    end
  end

  def install_node_modules
    puts `cd #{Rails.root}/app/assets/javascripts && npm i`
  end

  def symlink_node_modules_dir_for_unit_tests
    files = "#{Rails.root}/app/assets/javascripts/node_modules #{Rails.root}/spec/webface/"
    unless File.exists?("#{Rails.root}/spec/webface/node_modules")
      puts "   Symlinking ".colorize(:green) + files
      `ln -s #{files}`
    else
      puts "   Symlink already exists ".colorize(:light_blue) + files
    end
  end

  def symlink_webface_dir
    files = "#{Rails.root}/#{@webface_path}/lib #{Rails.root}/spec/webface/webface_source"
    unless File.exists?("#{Rails.root}/spec/webface/webface_source")
      puts "   Symlinking ".colorize(:green) + files
      `ln -s #{files}`
    else
      puts "   Symlink already exists ".colorize(:light_blue) + files
    end
  end


end
