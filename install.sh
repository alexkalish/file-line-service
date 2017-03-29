 #!/usr/bin/env bash

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then

  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"

elif [[ -s "/usr/local/rvm/scripts/rvm" ]] ; then

  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"

else

  printf "ERROR: An RVM installation was not found.\n"

fi 

# Install Ruby and create gemset.
rvm install ruby-2.3.3
rvm use ruby-2.3.3@file-line-service --create

# Install Rubygems.
bundle install