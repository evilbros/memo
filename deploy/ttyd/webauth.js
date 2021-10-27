#!/usr/bin/env node

// ============================================================================
// (read -sp 'input:' x; node -e "console.log(require('crypto').createHmac('sha256', 'hash_key').update('$x').digest('hex'))")

const config = {
    token_key: '16 bytes',
    hash_key:  '16 bytes',
    pwd_hash:  'password hash',
    user:      'admin',
};

// ============================================================================
// token
// ============================================================================

const crypto = require('crypto');

// ============================================================================

const ENCRYPT_KEY  = Buffer.from(config.token_key, "hex");
const TOKEN_EXPIRE = 3600;

// ============================================================================

function tk_encode(user) {
    // user|expire

    let data = `${user}|${Math.floor(Date.now() / 1000) + TOKEN_EXPIRE}`;

    let iv = crypto.randomBytes(16);
    let c  = crypto.createCipheriv("AES-128-CBC", ENCRYPT_KEY, iv);

    let r = c.update(data, "utf8", "hex");
    r += c.final("hex");

    return iv.toString("hex") + r;
}

function tk_decode(tk) {
    if (!tk || tk.length < 32) return null;

    try {
        let data = tk.slice(32);

        let iv = Buffer.from(tk.slice(0, 32), "hex");
        let d = crypto.createDecipheriv("AES-128-CBC", ENCRYPT_KEY, iv);

        let r = d.update(data, "hex", "utf8");
        r += d.final("utf8");

        let arr = r.split('|');
        if (arr.length != 2) return null;

        return {
            user:   arr[0],
            expire: Number(arr[1]),
        };
    } catch {
        return null;
    }
}

function tk_verify(tk, user) {
    let obj = tk_decode(tk);
    return obj && obj.user == user && obj.expire > Date.now() / 1000;
}



// ============================================================================
// http
// ============================================================================

global._A_ = http_handler => (req, res) => http_handler(req, res).catch(console.error);

// ============================================================================

const http = require('http');
const qs   = require('querystring');

// ============================================================================

let router = {
    _handlers: {
        'GET':  [],
        'POST': [],
    }
};

router.get = (mpath, f) => {
    router._handlers['GET'].push({mpath, f});
}

router.post = (mpath, f) => {
    router._handlers['POST'].push({mpath, f});
}

router.sort = () => {
    router._handlers['GET'].sort((a, b) => b.length - a.length);
    router._handlers['POST'].sort((a, b) => b.length - a.length);
}

// ============================================================================

let server = http.createServer(_A_(async (req, res) => {
    let arr = router._handlers[req.method];
    if (arr) {
        for (let v of arr) {
            if (req.url.startsWith(v.mpath)) {
                // query
                req.query = {};
                for (let [k, v] of new URL(req.url, 'http://localhost').searchParams) {
                    req.query[k] = v;
                }

                // body
                req.setEncoding('utf8');
                let data = '';
                for await (let c of req) {
                    data += c;
                }
                req.body = qs.parse(data);

                // remote ip
                let xfwd = req.headers['x-forwarded-for'];
                req.ip = xfwd ? xfwd.split(/\s*,\s*/)[0] : req.socket.remoteAddress;

                // handle
                return await v.f(req, res);
            }
        }
    }

    res.statusCode = 404;
    res.end('not found');
}));

server.listen(8000, () => {
    router.sort();
    console.log('auth server listening :8000');
});

// ============================================================================

const login_limit = 3;
var   login_fails = {};

function check_login_limit(ip) {
    let n = login_fails[ip] || 0;
    return n < login_limit;
}

function add_login_fail(ip) {
    let n = login_fails[ip] || 0;
    login_fails[ip] = n + 1;
}

setInterval(() => {
    login_fails = {};
}, 60 * 1000);

// ============================================================================

router.get('/lab/login', async (req, res) => {
    res.statusCode = 200;
    res.end(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Login</title>
            <style>
                input {
                    display: block;
                    margin: 100px auto;
                    width: 200px;
                    height: 30px;
                    font-size: 1.5em;
                }
            </style>
        </head>
        <body>
            <form method="post">
                <input type="password" name="pwd" placeholder="password" autofocus>
            </form>
        </body>
        </html>
    `);
});

router.post('/lab/login', async (req, res) => {
    let q = req.query;
    let body = req.body;

    let rurl = q.url || '/lab/';

    // check login limit
    if (!check_login_limit(req.ip)) {
        res.statusCode = 404;
        res.end('not found');
        return;
    }

    // verify password
    let hash = crypto.createHmac('sha256', config.hash_key)
        .update(body.pwd)
        .digest('hex');

    res.statusCode = 302;
    if (hash == config.pwd_hash) {
        res.setHeader('Set-Cookie', `tk=${tk_encode(config.user)}; Path=/lab; Secure; HttpOnly`);
        res.setHeader('Location', rurl);
    } else {
        add_login_fail(req.ip);
        res.setHeader('Location', req.url);
    }
    res.end();
});

router.get('/lab/auth', async (req, res) => {
    let cookies = (req.headers['cookie'] || '').split(/\s*;\s*/);
    for (let c of cookies) {
        let arr = c.split('=');
        if (arr[0] == 'tk') {
            if (tk_verify(arr[1], config.user)) {
                res.statusCode = 200;
                res.end();
                return;
            }
            break;
        }
    }

    res.statusCode = 401;
    res.end('Not authorized!');
});
