class WebfaceGenerator < Rails::Generators::Base

  source_root File.expand_path('templates', __dir__)

  def add_webface
    # We'll later change this to fetching webface.js as a node_module, but not now.
    gitmodules = File.readlines("#{Rails.root}/.gitmodules")
    unless gitmodules.join("\n").include?("webface.js.git")
      `cd #{Rails.root}/app/assets/javascripts/ && git submodule add git@gitlab.com:hodl/webface.js.git`
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
    copy_file "webface_test_server.js", "spec/webface/test_server.js"
    copy_file "run_webface_test", "spec/webface/run_test"
    `chmod +x #{Rails.root}/spec/webface/run_test`
    copy_file "mocha.css", "spec/webface/mocha.css"
    copy_file "mocha.pug", "spec/webface/mocha.pug"
    copy_file "test_utils.js", "spec/webface/test_utils.js"
    copy_file "webface.test.js", "spec/webface/webface.test.js"
    copy_file "webface_init.js", "spec/webface/webface_init.js"
    copy_file "test_animator.js", "spec/webface/test_animator.js"
    copy_file "my_component.test.js", "spec/webface/components/my_component.test.js"

    copy_file "application.js", "app/assets/javascripts/application.js"
    gsub_file "app/assets/javascripts/application.js", "path_to_webface.js", @webface_path.sub(/\A.*app\/assets\/javascripts\//, "") + "/lib/webface.js"
  end

  def add_node_modules_to_gitignore
    `echo "spec/webface/node_modules"           >> #{Rails.root}/.gitignore` unless File.read("#{Rails.root}/.gitignore").include?("spec/webface/node_modules")
    `echo "app/assets/javascripts/node_modules" >> #{Rails.root}/.gitignore` unless File.read("#{Rails.root}/.gitignore").include?("app/assets/javascripts/node_modules")
  end

  def copy_package_json
    copy_file "#{Rails.root}/#{@webface_path}/package.json", "app/assets/javascripts/package.json"
    copy_file "#{Rails.root}/#{@webface_path}/package-lock.json", "app/assets/javascripts/package-lock.json"
  end

  def create_symlinks
    create_symlink("#{Rails.root}/app/assets/javascripts", "#{Rails.root}/spec/webface/source")
    create_symlink("#{Rails.root}/app/assets/javascripts/node_modules", "#{Rails.root}/spec/webface/")
    create_symlink("#{Rails.root}/#{@webface_path}", "#{Rails.root}/spec/webface/webface_source")
    create_symlink "#{Rails.root}/app/assets/javascripts/package.json", "#{Rails.root}/spec/webface/"
    create_symlink "#{Rails.root}/app/assets/javascripts/package-lock.json", "#{Rails.root}/spec/webface/"
  end

  def install_node_modules
    puts `cd #{Rails.root}/app/assets/javascripts && npm i`
  end

  private

    def create_symlink(from, to)
      files = "#{to} #{from}"
      unless File.exists?(to)
        puts "   Symlinking ".colorize(:green) + from + " -> " + to
        `ln -s #{files}`
      else
        puts "   Symlink already exists ".colorize(:light_blue) + to
      end
    end


end
