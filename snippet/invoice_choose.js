#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// ============================================================================

function makeList(dir) {
    let files = fs.readdirSync(dir);
    return files.map(v => {
        let value = Number(v.match(/([0-9.]+)\./)[1]);
        return {
            file: v,
            type: v.match(/^(.+)_/)[1],
            value,
            roundValue: Math.ceil(value),
        }
    });
}

function choose(limit, list) {
    // init
    let f = new Array(list.length + 1);
    for (let i = 0; i < f.length; i++) {
        f[i] = new Array(limit + 1).fill(0);
    }

    // dp
    for (let i = 1; i <= list.length; i++) {
        for (let j = 1; j <= limit; j++) {
            let vi = list[i - 1];
            if (j >= vi) {
                f[i][j] = Math.max(
                    f[i - 1][j],
                    f[i - 1][j - vi] + vi,
                );
            } else {
                f[i][j] = f[i - 1][j];
            }
        }
    }

    // result
    let r = f[list.length][limit];

    // find selected indexes
    let i = list.length;
    let j = r;
    let selected = [];

    while (j > 0) {
        while (i > 0 && f[i][j] == j)
            i--;

        selected.push(i);
        j -= list[i];
    }

    /////////////////////////////////////////////
    // for (let j = 1; j <= limit; j++) {
    //     for (let i = 1; i <= list.length; i++) {
    //         process.stdout.write(f[i][j] + " ");
    //     }
    //     console.log();
    // }
    /////////////////////////////////////////////

    return [r, selected.reverse()];
}

// ============================================================================

/*
    let limit = 116;
    let list = [11, 7, 15, 13, 61, 9, 14, 18, 73, 54, 40, 33, 82];
    let [r, selected] = choose(limit, list);
    let values = selected.map(i => list[i])
    console.log(r);
    console.log(selected);
    console.log(values);
*/

// ============================================================================

let dir = "available invoice file dir";
let user = 'user-name';

// ============================================================================

// args
var args = process.argv.slice(2);
if (args.length < 1) {
    console.error('args: limit-amount');
    process.exit(1);
}
var limit = Number(args[0]);
if (Number.isNaN(limit) || !Number.isInteger(limit)) {
    console.error('limit amount should be an integer');
    process.exit(1);
}

// check if already done
if (fs.readdirSync(path.join(dir, '..')).some(v => v.startsWith(user))) {
    console.error('already done');
    process.exit(1);
}

// scan file names
let infos = makeList(dir);

// choose
let [r, selected] = choose(limit, infos.map(v => v.roundValue));

// group
let groups = {};
for (let info of selected.map(i => infos[i])) {
    let g = groups[info.type];
    if (!g) {
        g = {
            infos: [],
        };
        groups[info.type] = g;
    }
    g.infos.push(info);
}

// group total: change to cent and back to yuan to prevent floating errors
let total = 0;
Object.keys(groups).forEach(type => {
    let cent = groups[type].infos.reduce((a, v) => a + v.value * 100, 0);
    groups[type].total = cent / 100;
    total += cent;
});
total /= 100;

// file system operations
Object.keys(groups).forEach(type => {
    let dirName = path.join(dir, `../${user}_${total}`, `${type}_${groups[type].total}`);
    fs.mkdirSync(dirName, { recursive: true });

    for (let info of groups[type].infos) {
        fs.renameSync(path.join(dir, info.file), path.join(dirName, info.file));
    }
});

console.log('available sum:', infos.reduce((a, v) => a + v.value * 100, 0) / 100);
console.log('optimal sum:', selected.map(i => infos[i]).reduce((a, v) => a + v.value, 0));
console.log('optimal rounded sum:', r);
