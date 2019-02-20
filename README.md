# WebfaceRails
RubyOnRails integration with Webface.js

Installation
------------
add `gem 'webface_rails'` to Gemfile and run `bundle install`

Running generators
------------------
To run the generator:

`rails generate webface` or `rails g webface`

By default it uses `Rails.root` path to install the gem. You can pass `root_path` argument to redefine root path in your project. It might be helpful when installing the gem into Rails Engine, e.g.:

`rails g webface --root_path absolute_path_to_your_project`

The generator will give you necessary files and dir structure inside the `spec/` dir to
run webface tests. To be more specific, it will do the following

1. Install webface as a submodule under `app/assets/javascripts/webface.js`. If you already have it installed, it will use the path specified in .gitmodules
2. Create webface unit test dir under `spec/webface`
3. Copy there a bunch of files necessary to run unit tests
4. Add `node_modules` dirs to .gitignore
5. Symlink your `app/assets/javascripts` into `spec/webface/source` and `app/assets/javascripts` into `spec/webface/webface_source`. This is necessary to properly import the files you're testing.
6. Install node_modules in `app/assets/javascripts`. If it doesn't have a `package.json` file, it will copy the one used by webface.
7. Symlink `app/assets/javascripts/node_modules` to `spec/webface/node_modules`
8. And finally, symlink the `app/assets/javascripts/webface.js` (or whatever the path is) into `spec/webface/webface_source`

Running unit tests
------------------
After you run the generators, you should be able to run unit tests with
a) `spec/webface/run_test` or
b) by launching the test server with `node spec/webface/test_server.js` and navigating your browser to `localhost:8080`. You should see a sample test there.

Look at the `spec/webface/components/my_component.test.js` file for examples on how to write unit tests.
Unit tests are written with mocha & chai.
