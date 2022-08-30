#!/bin/bash
docker run --rm -ti -v $(pwd):/charts:z -v $(pwd)/ct/ct.yaml:/ct.yaml:z quay.io/helmpack/chart-testing \
    sh -c "cd /charts ;  ct lint --all --config /ct.yaml --chart-dirs /charts/charts"
#docker run --rm -ti -v $(pwd):/charts:z -v $(pwd)/ct/ct.yaml:/ct.yaml:z quay.io/helmpack/chart-testing sh
