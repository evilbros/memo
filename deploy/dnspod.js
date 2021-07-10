#!/usr/bin/env node

require('./lib/ext');

var axios = require('axios');

var config;
try {
    config = require('./config.my.json');
} catch {
    config = require('./config.json');
}

// ============================================================================

function usage() {
    console.log("args: cmd [args...]");
    console.log("");
    console.log("cmd:");
    console.log("   list            list all 'A' records");
    console.log("   update ip       update configured records to point to 'ip'");
    console.log("");
    process.exit(1);
}

var args = process.argv.slice(2);
if (args.length < 1) {
    usage();
}

var cmd = args[0];
args = args.slice(1);

// ============================================================================

async function rec_list() {
    let {data} = await axios.post('https://dnsapi.cn/Record.List', {
        login_token: config.dnspod.api_key,
        format:      'json',
        domain:      'ioof.top',
        record_type: 'A',
    }, {
        headers: {
            'User-Agent': 'my ddns/1.0.0 (x@x.com)',
        },
    });

    console.log(data);
}

async function rec_update(rec, ip) {
    let {data} = await axios.post('https://dnsapi.cn/Record.Modify', {
        login_token: config.dnspod.api_key,
        format:      'json',
        domain:      'ioof.top',
        record_id:   rec.id,
        sub_domain:  rec.sub_domain,
        record_type: 'A',
        record_line: '默认',
        value:       ip,
    }, {
        headers: {
            'User-Agent': 'my ddns/1.0.0 (x@x.com)',
        },
    });

    console.log(data);
}

// ============================================================================

(async () => {
    switch (cmd) {
        case 'list':
            await rec_list();
            break;

        case 'update':
            let ip = args[0];
            if (!ip) usage();

            for (let rec of config.dnspod.records) {
                await rec_update(rec, ip);
                await sleep(1000);
            }

            break;
    }
})().catch(console.error);
