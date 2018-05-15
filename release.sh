#!/usr/bin/env bash
docker build -t doc_to_dash .
docker run --rm -v ~/.gem/:/root/.gem/ -v $(pwd):/gem/ doc_to_dash rake build && gem push pkg/*.gem
