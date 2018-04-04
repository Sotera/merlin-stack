#!/usr/bin/env bash
echo "Trying to start joshua @ "`date`

python /src/joshua-decoder/app.py \
  --bundle-dir  /src/apache-joshua-es-en-2016-11-18\
  --source-lang es\
  --target-lang en\
  --port        8002\
  --memory      16g

echo "joshua bailed out. Attempting restart @ "`date`
sleep 5
exit 1
