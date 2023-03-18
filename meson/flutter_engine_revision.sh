#! /usr/bin/env bash

echo $(flutter --version | grep Engine | awk '{print $NF}')
