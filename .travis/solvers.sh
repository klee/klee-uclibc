#!/bin/bash -x
# Make sure we exit if there is a failure
set -e
: ${SOLVERS?"Solvers must be specified"}

SOLVER_LIST=$(echo "${SOLVERS}" | sed 's/:/ /')

for solver in ${SOLVER_LIST}; do
  echo "Getting solver ${solver}"
  case ${solver} in
  Z3)
    echo "Z3"
    # Should we install libz3-dbg too?
    sudo apt-get -y install libz3 libz3-dev
    ;;
  *)
    echo "Unknown solver ${solver}"
    exit 1
  esac
done
