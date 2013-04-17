#!/bin/bash
#
# Copyright 2012 Google Inc. All Rights Reserved.
# Author: dominich@google.com (Dominic Hamon)

pgrep $@ > /dev/null || (sleep 10 && ($@ &))
