#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o errtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

$(aws ecr get-login --no-include-email --region eu-west-1)
docker build -t 692159125262.dkr.ecr.eu-west-1.amazonaws.com/volta-builder:latest .
docker push 692159125262.dkr.ecr.eu-west-1.amazonaws.com/volta-builder:latest