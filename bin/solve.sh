#!/bin/bash

bc << EOF
scale=8
$@
quit
EOF
