#!/usr/bin/env node

const { dnspod } = require("tencentcloud-sdk-nodejs-dnspod");
const { Client } = require("tencentcloud-sdk-nodejs-dnspod/tencentcloud/services/dnspod/v20210323/dnspod_client");

const DnsClient = dnspod.v20210323.Client;

// ============================================================================

var config;
try {
    config = require('./config.my.json');
} catch {
    config = require('./config.json');
}

// ============================================================================

/**@type {Client} */
var client;
function getClient() {
    if (!client) {
        client = new DnsClient({
            credential: {
                secretId: config.dnspod.secret_id,
                secretKey: config.dnspod.secret_key,
            },
        });
    }

    return client;
}

// ============================================================================

async function listRecords(recordType) {
    try {
        let c = getClient();
        const r = await c.DescribeRecordList({
            Domain: config.dnspod.domain,
            RecordType: recordType,
        });
        console.log(r);
    } catch (err) {
        console.error("listRecords error:", err);
    }
}

async function modifyRecord(recordId, subDomain, recordType, val) {
    try {
        let c = getClient();
        const r = await c.ModifyRecord({
            Domain: config.dnspod.domain,
            RecordId: recordId,
            SubDomain: subDomain,
            RecordType: recordType,
            RecordLine: "默认",
            Value: val,
            TTL: 600,
        });
        console.log('OK')
    } catch (err) {
        console.error("modifyRecordInList error:", err);
    }
}

async function createRecord(subDomain, recordType, val) {
    try {
        let c = getClient();
        const r = await c.CreateRecord({
            Domain: config.dnspod.domain,
            SubDomain: subDomain,
            RecordType: recordType,
            RecordLine: "默认",
            Value: val,
            TTL: 600,
        });
        console.log('OK. RecordId=', r.RecordId);
    } catch (err) {
        console.error("createRecord error:", err);
    }
}

async function deleteRecord(recordId) {
    try {
        let c = getClient();
        const r = await c.DeleteRecord({
            Domain: config.dnspod.domain,
            RecordId: recordId,
        });
        console.log('OK');
    } catch (err) {
        console.error("deleteRecord error:", err);
    }
}

// ============================================================================

function usage() {
    console.log("args: cmd [args...]");
    console.log("");
    console.log("cmd:");
    console.log("   list [type]                     list all records of 'type'");
    console.log("   update ip                       update configured records to point to 'ip'");
    console.log("   create subdomain type val       create a subdomain of 'type' and 'val'");
    console.log("   delete recordid                 delete a record with 'recordid'");
    console.log("");
    process.exit(1);
}

var args = process.argv.slice(2);
if (args.length < 1) {
    usage();
}

var cmd = args[0];
args = args.slice(1);

(async () => {
    switch (cmd) {
        case 'list':
            let tp = args[0];

            await listRecords(tp);
            break;

        case 'update':
            {
                let ip = args[0];
                if (!ip) usage();

                for (let rec of config.dnspod.records) {
                    await modifyRecord(rec.id, rec.sub_domain, 'A', ip);
                    await sleep(1000);
                }
            }
            break;

        case 'create':
            {
                let subDomain = args[0];
                let tp = args[1];
                let val = args[2];
                if (!val) usage();

                await createRecord(subDomain, tp, val);
            }
            break;

        case 'delete':
            {
                if (args.length < 1) usage();

                for (let v of args) {
                    let recordId = Number(v)
                    if (!recordId) {
                        console.error('invalid recordId:', v);
                        continue;
                    }

                    await deleteRecord(recordId);
                }
            }
            break;
    }
})().catch(console.error);
