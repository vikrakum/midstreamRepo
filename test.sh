#!/bin/bash

# define a function to display the help message
show_help() {
  echo "Usage: myscript [options]"
  echo ""
  echo "Options:"
  echo "  --option1     Description of option 1"
  echo "  --option2     Description of option 2"
  echo "  -h, --help    Show this help message"
}

# parse command-line options
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --option1) option1=1;;
    --option2) option2=1;;
    -h|--help) show_help; exit 0;;
    *) echo "Unknown parameter passed: $1"; exit 1;;
  esac
  shift
done

# main script logic goes here
echo "Hello, world!"
