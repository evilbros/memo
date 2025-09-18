#!/usr/bin/env node

const http = require('http');
const qs = require('querystring');
const cp = require('child_process');

// ============================================

var PORT = 16601;

http.createServer((req, res) => {
    // url
    let url = new URL(req.url, 'http://host');

    // read body
    req.setEncoding('utf8');
    let body = '';
    req.on('data', data => {
        body += data;
    });
    req.on('end', () => {
        // GET: query
        let query = {};
        for (let [k, v] of url.searchParams.entries()) {
            query[k] = Number.isNaN(Number(v)) ? v : Number(v);
        }
        req.query = query;

        // POST: body
        if (req.method == 'POST') {
            switch (req.headers['content-type']) {
                case 'application/x-www-form-urlencoded':
                    body = qs.parse(body);
                    break;

                case 'application/json':
                    try {
                        body = JSON.parse(body);
                    } catch {
                        body = {};
                    }
                    break;
            }
            req.body = body;
        }

        // route
        let h = getRouteHandler(req.method, url.pathname);
        h(req, res);
    });
}).listen(PORT);

console.log('server started on port:', PORT);

// ============================================

var BASE_DIR = "";
var routes = [];

function get(path, f) {
    let method = 'GET';
    path = BASE_DIR + path;
    routes.push({ method, path, f });
    sortRoutes();
}

function post(path, f) {
    let method = 'POST';
    path = BASE_DIR + path;
    routes.push({ method, path, f });
    sortRoutes();
}

function sortRoutes() {
    routes.sort((a, b) => b.path.length - a.path.length);
}

function getRouteHandler(method, path) {
    for (let e of routes) {
        if (e.method != method) continue;

        if (path.startsWith(e.path)) {
            return e.f;
        }
    }
    return defaultRoutes;
}

function defaultRoutes(req, res) {
    res.end('default');
}

// ============================================

function shell_exec(cmd, ondata) {
    let child = cp.exec(cmd);

    child.stdout.on('data', data => {
        if (ondata) ondata(data);
    });
    child.stderr.on('data', data => {
        if (ondata) ondata(data);
    });
    child.on('close', code => {
        if (ondata) ondata(null);
    });
}

// ============================================

post('/feishu', (req, res) => {
    let text = req.body.text;

    res.statusCode = 200;
    res.setHeader('Transfer-Encoding', 'chunked');

    shell_exec(`/data/server/update/warn/send-feishu.sh "${text}"`, data => {
        if (data) {
            res.write(data);
        } else {
            res.end();
        }
    });
});

post('/dingding', (req, res) => {
    let text = req.body.text;

    res.statusCode = 200;
    res.setHeader('Transfer-Encoding', 'chunked');

    shell_exec(`/data/server/update/warn/send-dingding.sh "${text}"`, data => {
        if (data) {
            res.write(data);
        } else {
            res.end();
        }
    });
});
