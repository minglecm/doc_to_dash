# DocToDash

DocToDash converts documentation files (at the moment only YARD) into a classes and methods docset that can then be loaded into the docset viewing program: Dash.

## Installation

Add this line to your application's Gemfile:

    gem 'doc_to_dash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install doc_to_dash

## Options

<table>
    <tr>
        <th>Key</th>
        <th>Default</th>
        <th>Description</th>
        <th>Required</th>
    </tr>

    <tr>
        <td>:docset_name</td>
        <td>DefaultDocset</td>
        <td>What the file will be called.  EX: DefaultDocset.docset</td>
        <td>Yes</td>
    </tr>

    <tr>
        <td>:docset_output_path</td>
        <td>doc/</td>
        <td>Where the file above will be stored EX: doc/DefaultDocset.docset</td>
        <td>Yes</td>
    </tr>

    <tr>
        <td>:icon_path</td>
        <td>nil/</td>
        <td>The icon file that will be put in the docset.  Shown in Dash.</td>
        <td>No</td>
    </tr>

    <tr>
        <td>:doc_input_path</td>
        <td>nil/</td>
        <td>The directory that the doc files will be coming from.  EX: /Users/Caleb/web/my_site/doc/yard</td>
        <td>Yes</td>
    </tr>

    <tr>
        <td>:doc_save_folder</td>
        <td>docs/</td>
        <td>Where inside the docset the docs will be copied to (not really important, just here if you need to change it)</td>
        <td>Yes</td>
    </tr>

    <tr>
        <td>:verbose</td>
        <td>true</td>
        <td>Spits out messages with "puts" showing what is going on.</td>
        <td>Yes</td>
    </tr>

    <tr>
        <td>:parser</td>
        <td>DocToDash::YardParser</td>
        <td>Parser to use to pull out classes and modules.  YARD is only supported at the moment.</td>
        <td>Yes</td>
    </tr>
</table>

## Usage

Generate YARD documentation (or as time progresses and we support rdoc, generate that). This will output your Rails application's YARD documentation to doc/yard:

    $ yardoc app/**/*.rb lib/**/*.rb --protected --private --embed-mixins --output-dir doc/yard/

Require doc_to_dash

    require 'doc_to_dash'

Tell doc_to_dash to generate a docset:

    DocToDash::DocsetGenerator.new(:docset_name => 'MyApplication', :doc_input_path => '/web/myapp/doc/yard', :icon_path => '~/icon.png', :docset_output_path => '/users/test/docsets').run

This will create a docset in the docset_output_path then you just need to load the docset into Dash.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
