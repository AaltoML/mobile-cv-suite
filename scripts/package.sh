#!/bin/bash
# Package built artefacts as an archive file
set -eux
# TODO: OSX build
DIR=build/host
(find $DIR/include/ \
  && find $DIR/lib/ -name "*.a*" -o -name "*.so*" \
  && find $DIR/share/doc/ && find $DIR/share/licenses/ &&
  echo scripts/mobile-cv-suite-config.cmake &&
  echo mobile-cv-suite-config.cmake) | \
  tar -cf build/mobile-cv-suite.tar.gz -T -
