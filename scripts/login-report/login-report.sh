#!/bin/bash

_tmpdir=`mktemp -d`
( aureport -l -i --summary --start recent
  echo
  ausearch --start recent --raw | aulast --proof --stdin --bad
) | enscript -t "Login Report" -o - | ps2pdf - $_tmpdir/login-report.pdf

mail -a $_tmpdir/login-report.pdf -s "Login Report" \
  your-email-here@domain.com \
  </dev/null
rm -rf $_tmpdir

