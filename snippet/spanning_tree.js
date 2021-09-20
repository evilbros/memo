// minimum spanning tree using kruskal algorithm
//  * 'ds' is the array representation of disjoint set
//  * dj-set merges with path compression (set members points directly to root)
//  * dj-set merges smaller-nodes set to larger-nodes set

var conns = {
    "1-2": {
        rgns: [1, 2],
    },
    "2-3": {
        rgns: [2, 3],
    },
    "3-4": {
        rgns: [3, 4],
    },
    "2-4": {
        rgns: [4, 2],
    },
    "1-3": {
        rgns: [3, 1],
    },
    "4-5": {
        rgns: [4, 5],
    },
    "1-5": {
        rgns: [5, 1],
    },
}

function mst() {
    let r  = []; // result
    let ds = []; // disjoint set

    // calc vertex count
    let m = {};
    Object.keys(conns).map(k=>conns[k]).forEach(v=>v.rgns.forEach(id=>m[id]=true));
    let cnt = Object.keys(m).length;

    // init dj-set
    for (let i = 1; i <= cnt; i++) {
        ds[i - 1] = [i, 1]; // [parent, count]
    }

    // mst
    for (let k in conns) {
        let conn = conns[k];

        // test edge
        console.log("\ntest edge:", conn);
        let c = [];
        conn.rgns.forEach(v => {
            c.push(ds[v - 1][0]);
        });
        console.log("in sets:", c);

        if (c[0] == c[1]) {
            // both vertices are in the same set: cycle detected
            console.log('cycle detected. discard');
            continue;
        } else {
            // in different sets: merge

            // make c[0] the smaller node count
            if (ds[c[0] - 1][1] > ds[c[1] - 1][1]) {
                [c[0], c[1]] = [c[1], c[0]];
            }

            // merge c[0] -> c[1]
            console.log("merge:", c[0], c[1]);
            let set1 = ds[c[1] - 1];
            for (let i = 1; i <= cnt; i++) {
                if (ds[i - 1][0] == c[0]) {
                    ds[i - 1] = set1;
                    set1[1]++;
                }
            }

            // add the edge
            r.push(conn.rgns);
        }
    }

    return r;
}

let r = mst();
console.log("\nresult => ", r);

/*
    test edge: { rgns: [ 1, 2 ] }
    in sets: [ 1, 2 ]
    merge: 1 2

    test edge: { rgns: [ 2, 3 ] }
    in sets: [ 2, 3 ]
    merge: 3 2

    test edge: { rgns: [ 3, 4 ] }
    in sets: [ 2, 4 ]
    merge: 4 2

    test edge: { rgns: [ 4, 2 ] }
    in sets: [ 2, 2 ]
    cycle detected. discard

    test edge: { rgns: [ 3, 1 ] }
    in sets: [ 2, 2 ]
    cycle detected. discard

    test edge: { rgns: [ 4, 5 ] }
    in sets: [ 2, 5 ]
    merge: 5 2

    test edge: { rgns: [ 5, 1 ] }
    in sets: [ 2, 2 ]
    cycle detected. discard

    result =>  [ [ 1, 2 ], [ 2, 3 ], [ 3, 4 ], [ 4, 5 ] ]
*/
