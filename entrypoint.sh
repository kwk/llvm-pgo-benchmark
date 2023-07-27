#!/usr/bin/bash

function print_usage()
{
cat <<EOF >&2
Usage:

  podman run -it --rm pgo <TEST>"

where <TEST> be one of the following:

  amalgamation           - compiles the sqlite merge of C source files (aka amalgamation)
  compile-clang-source   - compiles the clang/lib/AST/ExprConstant.cpp file
  llvm-test-suite        - runs the llvm-test-suite and compares the results
EOF
}

if [[ $# -ne 1 ]]; then
print_usage
exit 1
fi

TEST=$1

if [[ "$TEST" != "amalgamation" && "$TEST" != "compile-clang-source" && "$TEST" != "llvm-test-suite" ]]; then
    print_usage
    exit 1
fi

./entrypoint-$TEST.sh
