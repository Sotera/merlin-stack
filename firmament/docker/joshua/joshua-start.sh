#!/usr/bin/env bash
echo "Trying to start joshua @ "`date`

python /src/joshua-decoder/app.py \
  --bundle-dir  /src/apache-joshua-ar-en-2016-11-18 /src/apache-joshua-fa-en-2016-11-18 /src/apache-joshua-es-en-2016-11-18\
  --source-lang ar                                  fa                                  es\
  --target-lang en                                  en                                  en\
  --port        8002                                8003                                8004\
  --memory      8g                                  8g                                  16g

echo "joshua bailed out. Attempting restart @ "`date`
sleep 5
exit 1
