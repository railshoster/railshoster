h2. 0.0.1

* Implementation of init command started.
* Current status: 
** Decode and parse credentials - done
** Gather Git Repository URL using git gem - done
** Write deploy.rb
** Capify project

h2. 0.0.2

* deploy.rb now creates a symlink to database.yml with -f (force) and overwrites an eventually existing database.yml from the customer's repository.

h3. 0.0.3

* Added travis testing meta data.
* Added RSpec tests for basic functionality.
* Fixed a Ruby 1.9.x issue.
* Enhanced error messages for invalid application tokens.
* Initial README.
