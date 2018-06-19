import * as find from 'find';
import * as async from 'async';
import * as lineDriver from 'line-driver';
import * as path from 'path';

const regex = /(\s|")([^"]\S+?:\d{1,4})\/(\S+?):(\S+?)($|\s|")/g;
console.log(`Adding tags to build scripts`);

const dockerRegistryNames = [
  //Note that first address will go where only one is appropriate (_run.sh, Dockerfile, docker-provision.json)
  //'docker-registry.parrot.keyw:5000'
  '52.0.211.45:5000'
  //Any other addresses will only go in tag switches in _build.sh
];

const excludeImages = [
  'portainer'
];

process.on('uncaughtException', (err: Error) => {
  const uncaughtExceptionMessage = `UncaughtException [HALT]: ${err.message}`;
  console.error(uncaughtExceptionMessage);
  //No way to recover from uncaughtException, bail out now
  process.exit(1);
});

function escapeRegExp(str: string) {
  return str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
}

function replaceAll(str: string, find, replace) {
  return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
}

let counter = 0;
async.waterfall([
  (cb) => {
    async.each([
        '_build.sh'
        , '_run.sh'
        , 'docker-provision.json'
        , 'Dockerfile'
      ],
      (filename, cb) => {
        find.file(filename, path.resolve(__dirname, 'docker'), (files) => {
          files = files.reverse();
          //Use async.eachSeries to preserve order for delete script (so dependent images aren't deleted first)
          async.eachSeries(files, (file, cb) => {
            //const outFile = path.resolve(__dirname, `tmp${++counter}.txt`);
            const pathFragments = file.split('/');
            const imageBaseName = pathFragments[pathFragments.length - 3];
            if (excludeImages.indexOf(imageBaseName) > -1) {
              console.error(`Excluding: ${file}`);
              return cb();
            }
            /*            if(file !== '/home/jreeme/src/parrot-stack/firmament/docker/alpine/3.7/_build.sh'){
                          return cb();
                        }*/
            console.log(`Doing ${file}`);
            let skipReplace = false;
            lineDriver.write({
              in: file,
              //out: outFile,
              line: (props, parser) => {
                const line = parser.line;
                if (skipReplace || line.includes('NO_AUTO_VERSION')) {
                  parser.write(line);
                  return skipReplace = true;
                }
                regex.lastIndex = 0;
                const resultArray = regex.exec(line);
                if (filename === '_build.sh') {
                  if (resultArray) {
                    const imageBaseName = resultArray[3];
                    parser.write('#!/usr/bin/env bash');
                    let newLine = 'docker build --rm';
                    dockerRegistryNames.forEach((dockerRegistryName) => {
                      newLine += ` -t ${dockerRegistryName}/${imageBaseName}:latest`;
                    });
                    newLine += ' .';
                    parser.write(newLine);
                  }
                } else {
                  if (resultArray) {
                    let newLine = replaceAll(line, resultArray[2], dockerRegistryNames[0]);
                    parser.write(newLine);
                  } else {
                    parser.write(line);
                  }
                }
              },
              write: (props, parser) => {
                cb();
              }
            });
          }, cb);
        });
      }, cb);
  }
], (err/*, result*/) => {
  err && console.log(err.message);
  !err && console.log(`Adding tags to build scripts: FINISHED`);
  process.exit(err ? 1 : 0);
});



