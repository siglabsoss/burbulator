'use strict';

const templates = require('../lib/templates.js');
const range = require('lodash.range');
const yargs = require('yargs');
const path = require('path');
const fs = require('fs-extra');

const pos = props =>
    props.positional('project', {
        describe: 'project description file (JS or JSON)',
        type: 'string'
    }).positional('output', {
        describe: 'path to the output files',
        type: 'string'
    });

const generateTb = props => {
    pos(props);
    const argv = props.argv;
    const project = argv.project || './project.js';
    const projPath = path.resolve(project);
    const outputPath = path.resolve(argv.output || path.dirname(project));
    const proj = require(projPath);

    Object.keys(templates).map(fileName => {
        const fn = templates[fileName];
        const body = fn(proj);
        fs.outputFile(path.resolve(outputPath, fileName), body, errW => {
            if (errW) {
                throw errW;
            }
        });
    });
};

const toInt32Hex = val => ('00000000' + (val >>> 0).toString(16)).slice(-8);

const toHex = width => val => {
    const acc = Array.isArray(val)
        ? val.map(toInt32Hex).reverse().join('')
        : toInt32Hex(val);
    return ('00000000' + acc).slice(-Math.ceil(width / 4));
};

const randFormula = width => () =>
    Array(Math.ceil(width / 32))
        .fill(0)
        .map(() => Math.pow(2, 32) * Math.random());

const generateData = props => {
    pos(props);
    const argv = props.argv;
    const project = argv.project || './project.js';
    const projPath = path.resolve(project);
    const outputPath = path.resolve(argv.output || path.dirname(project));
    const proj = require(projPath);

    proj.targets.map(t => {
        const filePath = path.resolve(outputPath, t.data + '.mif');
        const dataLength = t.length || 32;
        const width = t.width || 8;
        const formula = t.formula || proj.formula || randFormula;
        const data = range(dataLength).map(formula(width)).map(toHex(width)).join('\n') + '\n';
        fs.outputFile(filePath, data, errW => {
            if (errW) {
                throw errW;
            }
        });
    });
};

yargs
    .command(
        ['gen [project] [output]', 'generate'],
        'Generate verilator testbench',
        generateTb
    )
    .command(
        ['mif [project] [output]', 'input'],
        'Generate input data files',
        generateData
    )
    .alias('p', 'project')
    .alias('o', 'output')
    .usage('Usage: $0 <command> [options]')
    .argv;
