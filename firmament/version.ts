import {ProcessCommandJson} from 'firmament-bash/js/interfaces/process-command-json';
import kernel from './inversify.config';
import * as find from 'find';
import * as fs from 'fs';
import * as async from 'async';
import * as lineDriver from 'line-driver';
import * as path from 'path';
import * as _ from 'lodash';
import {ExecutionGraph, ShellCommand} from "firmament-bash/js/custom-typings";

const version = '0.07.11';
const doAsyncBuild = false;

const processCommandJson = kernel.get<ProcessCommandJson>('ProcessCommandJson');
//const regex = /(\d+\.\d+\.\d+\.\d+):.*?\/.*?:(.+?)($|\s|")/g;
//const regex = /\s(.+?:\d{1,4})\/(.+?):(.+?)($|\s|")/g;
const regex = /(\s|")([^"]\S+?:\d{1,4})\/(\S+?):(\S+?)($|\s|")/g;
//let counter = 1;

console.log(`Writing out version ${version}`);

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

function createScriptWriteStream(scriptPath) {
    const writeStreamOptions = {
        flags: 'w',
        encoding: 'utf8',
        fd: null,
        mode: 0o755,
        autoClose: true
    };
    const streamPath = path.resolve(__dirname, scriptPath);
    const writeStream = fs.createWriteStream(streamPath, writeStreamOptions);
    writeStream.on('error', (err: Error) => {
        console.error(`Error writing to stream '${scriptPath}': ${err.message}`);
    });
    writeStream.write('#!/usr/bin/env bash\n');
    return writeStream;
}

const scriptStreamMap = {};

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
                        console.log(`Doing ${file}`);
                        let skipReplace = false;
                        lineDriver.write({
                            in: file,
                            //out: outFile,
                            line: (props, parser) => {
                                let line = parser.line;
                                if (skipReplace || line.includes('NO_AUTO_VERSION')) {
                                    parser.write(line);
                                    return skipReplace = true;
                                }
                                let resultArray = regex.exec(line);
                                regex.lastIndex = 0;
                                if (resultArray) {
                                    line = replaceAll(line, resultArray[4], version);
                                    if (path.basename(filename) === '_build.sh') {
                                        while (resultArray = regex.exec(line)) {
                                            scriptStreamMap['deleteImages'] = scriptStreamMap['deleteImages'] || createScriptWriteStream(`_delete_images_${version}.sh`);
                                            scriptStreamMap['deleteImages'].write(`docker rmi ${resultArray[0]}\n`);
                                            let targetRepoServerIp = `_pushTo_${replaceAll(resultArray[2], '.', '_')}`;
                                            targetRepoServerIp = replaceAll(targetRepoServerIp, ':', '_');
                                            scriptStreamMap[targetRepoServerIp] = scriptStreamMap[targetRepoServerIp] || createScriptWriteStream(`${targetRepoServerIp}.sh`);
                                            scriptStreamMap[targetRepoServerIp].write(`docker push ${resultArray[0]}\n`);
                                        }
                                        regex.lastIndex = 0;
                                    }
                                }
                                parser.write(line);
                            },
                            write: (/*props, parser*/) => {
                                cb();
                            }
                        });
                    }, cb);
                });
            }, (err) => {
                const scriptStreams = Object.keys(scriptStreamMap).map((key) => scriptStreamMap[key]);
                async.each(scriptStreams, (scriptStream, cb) => {
                    scriptStream.on('finish', () => {
                        cb();
                    });
                    scriptStream.end(`echo 'OK'`);
                }, (/*err*/) => {
                    cb(err);
                });
            });
    }
    , (cb) => {
        const buildAllDockerImages: ExecutionGraph = {
            description: "Build all Docker images in Parrot stack",
            options: {
                displayExecutionGraphDescription: true
            },
            asynchronousCommands: [],
            serialSynchronizedCommands: []
        };

        find.file('_build.sh', path.resolve(__dirname, 'docker'), (files) => {
            const workingDirectories = files.map(file => path.dirname(file));
            const syncPathFragments = [
                'alpine/3.7'
                , 'alpine-jre/3.7-8'
                , 'alpine-python/3.7-2.7'
                , 'hadoop-base'
            ];
            const syncWorkingDirectories = _.intersectionWith(workingDirectories, syncPathFragments, (directory: string, fragment: string) => {
                return directory.includes(fragment);
            });
            const asyncWorkingDirectories = _.without(workingDirectories, ...syncWorkingDirectories);
            const baseCommand: ShellCommand = {
                suppressOutput: false,
                suppressDiagnostics: false,
                suppressPreAndPostSpawnMessages: false,
                outputColor: "",
                useSudo: false,
                command: "/usr/bin/env",
                args: [
                    "bash",
                    "_build.sh"
                ]
            };

            function mapDirectoriesToCommands(directories: string[]): ShellCommand[] {
                return directories.map((workingDirectory) => {
                    return Object.assign({}, baseCommand, {
                        workingDirectory,
                        description: `Build Dockerfile @ ${workingDirectory}`,
                    });
                });
            }

            buildAllDockerImages.serialSynchronizedCommands = mapDirectoriesToCommands(syncWorkingDirectories);
            buildAllDockerImages.asynchronousCommands = mapDirectoriesToCommands(asyncWorkingDirectories);
            cb(null, buildAllDockerImages);
        });
    }
    , (buildAllDockerImages, cb) => {
        const copyOfBuildAllDockerImages: ExecutionGraph = Object.assign({}, buildAllDockerImages);
        copyOfBuildAllDockerImages.asynchronousCommands = [];
        processCommandJson.execute(copyOfBuildAllDockerImages, (err) => {
            cb(err, buildAllDockerImages);
        });
    }
    , (buildAllDockerImages, cb) => {
        const copyOfBuildAllDockerImages: ExecutionGraph = Object.assign({}, buildAllDockerImages);
        if (doAsyncBuild) {
            copyOfBuildAllDockerImages.serialSynchronizedCommands = [];
        } else {
            copyOfBuildAllDockerImages.serialSynchronizedCommands = copyOfBuildAllDockerImages.asynchronousCommands;
            copyOfBuildAllDockerImages.asynchronousCommands = [];
        }
        processCommandJson.execute(copyOfBuildAllDockerImages, cb);
    }
], (err/*, result*/) => {
    err && console.log(err.message);
    !err && console.log(`Writing out version ${version}: FINISHED`);
    process.exit(err ? 1 : 0);
});


