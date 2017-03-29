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

# Use the correct Ruby version.
rvm use ruby-2.3.3@file-line-service 

# Make sure the file exists and is readable.
if [[ ! -r $1 ]] ; then
  echo "file not found or not readable"
  exit
fi

# Determine if provided path is relative or absolute.
if [[ $1 =~ ^\/ ]] ; then
  FILE_PATH=$1
else
  FILE_PATH="../$1"
fi

echo $FILE_PATH

# Symlink the provided file name argument to the default location.
ln -sf $FILE_PATH config/file.txt

# Boot the app.
RAILS_ENV=production bundle exec rails s Puma
