#!/bin/bash

pushd packages/ipkbuild/speedifyunofficial/control/
rm ../control.tar.gz
tar --numeric-owner --group=0 --owner=0 -czf ../control.tar.gz ./*
popd

pushd packages/ipkbuild/speedifyunofficial/data
rm ../data.tar.gz
tar --numeric-owner --group=0 --owner=0 -czf ../data.tar.gz ./*
popd

pushd packages/ipkbuild/speedifyunofficial
rm ../../speedifyunofficial_1.0_all.ipk
tar --numeric-owner --group=0 --owner=0 -czf ../../speedifyunofficial_1.0_all.ipk ./debian-binary ./data.tar.gz ./control.tar.gz 
popd
