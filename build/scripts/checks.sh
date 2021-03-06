#!/bin/sh	

set -e

dirs=$(go list ./... | sed -e 's!github.com/contiv/volplugin!.!g' | grep -v ./vendor)
files=$(find . -type f -name '*.go' | grep -v ./vendor)

echo "Running gofmt..."
set +e
out="$(gofmt -s -l ${files})"
set -e
if [ "$(echo ${out} | wc -l)" -gt 1 ]
then
  echo 1>&2 "gofmt errors in:"
  echo 1>&2 "${out}"
  exit 1
fi

echo "Running ineffassign..."
[ -n "`which ineffassign`" ] || go get github.com/gordonklaus/ineffassign
for i in ${dirs}
do
  ineffassign $i
done

echo "Running golint..."
[ -n "`which golint`" ] || go get github.com/golang/lint/golint
set +e
out=$(golint ./... | grep -vE '^vendor')
set -e
if [ "$(echo ${out} | wc -l)" -gt 1 ]
then
  echo 1>&2 "golint errors in:"
  echo 1>&2 "${out}"
  exit 1
fi

echo "Running govet..."
set +e
out=$(go tool vet -composites=false ${dirs} 2>&1 | grep -v vendor)
set -e

if [ "$(echo ${out} | wc -l)" -gt 1 ]
then
  echo 1>&2 "go vet errors in:"
  echo 1>&2 "${out}"
  exit 1
fi
