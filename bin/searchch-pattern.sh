#!/bin/bash
$PATTERN=$1
find ./ -name "*.[hHCc]" -exec grep -wnH "$PATTERN" {} \;

