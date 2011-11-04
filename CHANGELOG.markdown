h2. 0.0.1

* Implementation of init command started.
* Current status: 
** Decode and parse credentials - done
** Gather Git Repository URL using git gem - done
** Write deploy.rb
** Capify project

h2. 0.0.2

* deploy.rb now creates a symlink to database.yml with -f (force) and overwrites an eventually existing database.yml from the customer's repository.

