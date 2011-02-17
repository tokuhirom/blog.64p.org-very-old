CREATE TABLE entry (
    entry_id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title varchar(255) not null,
    format varchar(25),
    body text,
    html text,
    ctime int unsigned not null,
    mtime int unsigned not null
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

