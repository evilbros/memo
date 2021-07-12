
// ============================================================================

global._A_ = http_handler => (req, res, next) => http_handler(req, res, next).catch(next);

// ============================================================================

global.setRunAt = (h, d, f) => {
    let ms = Math.max(d.getTime() - Date.now(), 0);

    if (ms > 0x7fffffff) {
        h.tid = setTimeout(() => setRunAt(h, d, f), 0x7fffffff);
    } else {
        h.tid = setTimeout(f, ms);
    }
}

global.clearRunAt = (h) => {
    if (h.tid) {
        clearTimeout(h.tid);
        h.tid = null;
    }
}

global.sleep = ms => new Promise(rv => setTimeout(rv, ms));

global.sleep_to = async d => {
    while (true) {
        let ms = Math.max(d.getTime() - Date.now(), 0);

        if (ms > 0x7fffffff) {
            await sleep(0x7fffffff);
        } else {
            await sleep(ms);
            break;
        }
    }
}

// ============================================================================

global.tonumber = (v) => {
    if (!v) return 0;

    let n = Number(v);
    return Number.isNaN(n) ? 0 : n;
}

global.shell_exec = async cmd => {
    return new Promise((rv, rj) => {
        let cp = require('child_process');
        cp.exec(cmd, {maxBuffer: 16 * 1024}, (err, stdout, stderr) => {
            if (err) {
                rj(`${stderr}\n${stdout}`);
                return;
            }

            rv(stdout);
        });
    });
}

// ============================================================================

Promise.limit = async (n, arr, f) => {
    let out = new Set();

    await Promise.all(arr.map(async v => {
        while (out.size >= n)
            await Promise.race(out);

        let p = f(v);
        out.add(p);
        await p;
        out.delete(p);
    }));
}

// ============================================================================

Date.fromString = function (v) {
    // format:
    //  [Y-m-d] [H:[M:[S]]]

    v = v.trim();

    let p = v.match(/^((\d+)\-(\d+)\-(\d+))?\s*((\d+)(:(\d+)(:(\d+))?)?)?$/);
    if (!p) throw `invalid date: ${v}`;

    p = p.map(v => {
        v = Number(v);
        return Number.isNaN(v) ? 0 : v;
    });

    let [y, m, d] = [p[2], p[3], p[4]];
    let [H, M, S] = [p[6], p[8], p[10]];

    if (y == 0 && m == 0 && d == 0) {
        let now = new Date();
        [y, m, d] = [now.getFullYear(), now.getMonth() + 1, now.getDate()];
    }

    return new Date(y, m - 1, d, H, M, S);
}

Date.parseRelative = function (t0, v) {
    // format:
    //  * @2 10:50:0    @相对t0当天0点的  天数 时:分:秒
    //  * +2 10:50:0    +相对t0的        天数 时:分:秒

    v = v.trim();

    if (!v.startWith("@") && !v.startWith("+"))
        throw `invalid relative-time: ${v}`;

    let prefix = v[0]
    let e      = v.slice(1);

    // relative to when
    if (prefix == "@")
        t0 = t0.StartOfDay();

    // relative amount
    let p = e.split(/[- :]+/);
    p = p.map(v => {
        v = Number(v);
        return Number.isNaN(v) ? 0 : v;
    });
    p = p.concat([0, 0, 0]);

    // return
    return t0.add('d', p[0]).add('H', p[1]).add('M', p[2]).add('S', p[3]);
}

Date.parseRepeat = function (v) {
    // format:
    //  unit/time-string

    v = v.trim();

    let ut = v.split('/');
    if (ut.length != 2)
        throw `invalid repeat-time: ${v}`;

    // unit
    let unit = ut[0];

    // time-string
    let p = ut[1].split(/[- :]+/);
    p = p.map(v => {
        v = Number(v);
        return Number.isNaN(v) ? 0 : v;
    });
    p = p.concat([0, 0, 0, 0]);

    // now
    let now = new Date();
    let [y, m, d, H, M, _] = [now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds()];
    let t;

    switch (unit) {
        case 'M':
            t = new Date(y, m, d, H, M, p[0]);
            break;

        case 'H':
            t = new Date(y, m, d, H, p[0], p[1]);
            break;

        case 'd':
            t = new Date(y, m, d, p[0], p[1], p[2]);
            break;

        case 'm':
            t = new Date(y, m, p[0], p[1], p[2], p[3]);
            break;

        case 'y':
            t = new Date(y, p[0] - 1, p[1], p[2], p[3], p[4]);
            break;

        case 'w':
            t = new Date(y, m, d, p[1], p[2], p[3]);
            t = t.add('d', p[0] % 7 - t.getDay());
            break;

        default:
            throw `invalid repeat-time unit: ${unit}`;
    }

    // return the key-time just has passed
    if (t.getTime() >= now.getTime())
        t = t.add(unit, -1);

    return {unit: unit, t: t};
}

Date.prototype.add = function (unit, n) {
    let d = new Date(this.getTime())

    switch (unit) {
        case 'S':
            d.setSeconds(this.getSeconds() + n);
            break;

        case 'M':
            d.setMinutes(this.getMinutes() + n);
            break;

        case 'H':
            d.setHours(this.getHours() + n);
            break;

        case 'd':
            d.setDate(this.getDate() + n);
            break;

        case 'm':
            d.setMonth(this.getMonth() + n);
            break;

        case 'y':
            d.setFullYear(this.getFullYear() + n);
            break;

        case 'w':
            d.setDate(this.getDate() + n * 7);
            break;

        default:
            throw `invalid time unit: ${unit}`;
    }

    return d;
}

Date.prototype.addDay = function (n) {
    return this.add('d', n);
}

Date.prototype.startOfDay = function () {
    let d = new Date(this.getTime());
    d.setHours(0, 0, 0, 0);
    return d;
}

Date.prototype.endOfDay = function () {
    let d = new Date(this.getTime());
    d.setHours(24, 0, 0, 0);
    return d;
}

Date.prototype.unix = function () {
    return Math.floor(this.getTime() / 1000);
}

Date.prototype.toDateString = function () {
    let [Y, m, d] = [
        this.getFullYear(),
        this.getMonth() + 1,
        this.getDate(),
    ];

    return `${Y}-${m}-${d}`;
}

Date.prototype.toString = function () {
    let [Y, m, d, H, M, S] = [
        this.getFullYear(),
        this.getMonth() + 1,
        this.getDate(),
        this.getHours(),
        this.getMinutes(),
        this.getSeconds(),
    ];

    return `${Y}-${m}-${d} ${H}:${M}:${S}`;
}

Date.prototype.toDateCompact = function () {
    let [Y, m, d] = [
        this.getFullYear(),
        (this.getMonth() + 1).toString().padStart(2, 0),
        this.getDate().toString().padStart(2, 0),
    ];

    return `${Y}${m}${d}`;
}

Date.prototype.toCompact = function () {
    let [Y, m, d, H, M, S] = [
        this.getFullYear(),
        (this.getMonth() + 1).toString().padStart(2, 0),
        this.getDate().toString().padStart(2, 0),
        this.getHours().toString().padStart(2, 0),
        this.getMinutes().toString().padStart(2, 0),
        this.getSeconds().toString().padStart(2, 0),
    ];

    return `${Y}${m}${d}${H}${M}${S}`;
}

// ============================================================================

Math.avg = function (...numbers) {
    return numbers.reduce((a, v) => a + v) / numbers.length;
}

Math.stdevp = function (...numbers) {
    let N = numbers.length;
    if (N < 1) return 0;

    let u = Math.avg(...numbers);
    return Math.sqrt(numbers.reduce((a, v) => a + (v - u) * (v - u), 0) / N);
}

Math.stdevs = function (...numbers) {
    let N = numbers.length;
    if (N < 2) return stdevp(...numbers);

    let u = Math.avg(...numbers);
    return Math.sqrt(numbers.reduce((a, v) => a + (v - u) * (v - u), 0) / (N - 1));
}

// ============================================================================

try {
    let axios = require('axios');
    let qs    = require('querystring');

    axios.defaults.transformRequest = (data, headers) => {
        switch (headers['Content-Type']) {
            case 'application/json':
                return typeof data == 'string' ? data : JSON.stringify(data);

            case 'application/octet-stream':
                return data;

            default:
                return typeof data == 'string' ? data : qs.stringify(data);
        }
    }
} catch {}

// ============================================================================
