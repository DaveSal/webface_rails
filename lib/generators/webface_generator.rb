class WebfaceGenerator < Rails::Generators::Base

  source_root File.expand_path('templates', __dir__)
  class_option :root_path, type: :string

  def add_webface
    @root_path = options["root_path"].present? ? options["root_path"] : Rails.root

    # We'll later change this to fetching webface.js as a node_module, but not now.
    gitmodules = File.readlines("#{@root_path}/.gitmodules") if File.file?("#{@root_path}/.gitmodules")

    if gitmodules.nil? || !gitmodules.join("\n").include?("webface.js.git")
      `rm -rf #{@root_path}/.git/modules/app/assets/javascripts/webface.js`
      `cd #{@root_path}/app/assets/javascripts/ && git submodule add git@gitlab.com:hodl/webface.js.git`
      gitmodules = File.readlines("#{@root_path}/.gitmodules") if File.file?("#{@root_path}/.gitmodules")
    end

    gitmodules.each do |line|
      if line.include?("webface") && line.include?("path =")
        @webface_path = line.strip.sub(/\Apath = /, "")
      end
    end
    puts "Webface path is #{@webface_path}"
  end

  def create_webface_unit_test_dir
    `mkdir -p #{@root_path}/spec/webface/`
    `mkdir -p #{@root_path}/spec/webface/components/`
  end

  def copy_unit_test_server
    copy_file "webface_test_server.js", "spec/webface/test_server.js"
    copy_file "run_webface_test", "spec/webface/run_test"
    `chmod +x #{@root_path}/spec/webface/run_test`
    copy_file "mocha.css", "spec/webface/mocha.css"
    copy_file "mocha.pug", "spec/webface/mocha.pug"
    copy_file "test_utils.js", "spec/webface/test_utils.js"
    copy_file "webface.test.js", "spec/webface/webface.test.js"
    copy_file "webface_init.js", "spec/webface/webface_init.js"
    copy_file "test_animator.js", "spec/webface/test_animator.js"
    copy_file "my_component.test.js", "spec/webface/components/my_component.test.js"

    copy_file "application.js", "app/assets/javascripts/application.js"
    gsub_file "app/assets/javascripts/application.js", "path_to_webface", @webface_path.sub(/\A.*app\/assets\/javascripts\//, "") + "/lib"
  end

  def add_node_modules_to_gitignore
    `echo "spec/webface/node_modules"           >> #{@root_path}/.gitignore` unless File.read("#{@root_path}/.gitignore").include?("spec/webface/node_modules")
    `echo "app/assets/javascripts/node_modules" >> #{@root_path}/.gitignore` unless File.read("#{@root_path}/.gitignore").include?("app/assets/javascripts/node_modules")
  end

  def copy_package_json
    copy_file "#{@root_path}/#{@webface_path}/package.json", "app/assets/javascripts/package.json"
    copy_file "#{@root_path}/#{@webface_path}/package-lock.json", "app/assets/javascripts/package-lock.json"
  end

  def create_symlinks
    create_symlink("#{@root_path}/app/assets/javascripts", "#{@root_path}/spec/webface/source")
    create_symlink("#{@root_path}/app/assets/javascripts/node_modules", "#{@root_path}/spec/webface/node_modules")
    create_symlink("#{@root_path}/#{@webface_path}", "#{@root_path}/spec/webface/webface_source")
    create_symlink "#{@root_path}/app/assets/javascripts/package.json", "#{@root_path}/spec/webface/package.json"
    create_symlink "#{@root_path}/app/assets/javascripts/package-lock.json", "#{@root_path}/spec/webface/package-lock.json"
  end

  def install_node_modules
    puts `cd #{@root_path}/app/assets/javascripts && npm i`
  end

  private

    def create_symlink(from, to)
      files = "#{from} #{to}"
      unless File.exist?(to)
        puts "   Symlinking ".colorize(:green) + from + " -> " + to
        `ln -s #{files}`
      else
        puts "   Symlink already exists ".colorize(:light_blue) + to
      end
    end

end
