var mg = db.getMongo();
mg.getDBNames().forEach(name => {
    if (!name.startsWith("GameDB")) return;

    db = mg.getDB(name);
    db.Player.find({},{"ip":1}).forEach(row => {
        print(row.ip)
    });
});

