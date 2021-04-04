create table database
(
    name     varchar(100) primary key,
    url      varchar(1000) not null,
    username varchar(100)  not null,
    password varchar(100)  not null
);