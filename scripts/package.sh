#!/bin/bash
# Package built artefacts as an archive file
set -eux
# TODO: OSX build
DIR=build
(find $DIR/host/include/ \
  && find $DIR/host/lib/ -name "*.a*" -o -name "*.so*" \
  && find $DIR/licenses/ -type f \
  && find $DIR/android/ -type f \
  && echo scripts/mobile-cv-suite-config.cmake && \
  echo mobile-cv-suite-config.cmake) | \
  tar -c -T - | gzip --best > build/mobile-cv-suite.tar.gz
