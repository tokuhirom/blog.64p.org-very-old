CREATE TABLE entry (
    entry_id INTEGER NOT NULL PRIMARY KEY,
    title varchar(255) not null,
    format varchar(25),
    body text,
    html text,
    ctime int unsigned not null,
    mtime int unsigned not null
);

