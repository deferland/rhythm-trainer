drop table if exists Users;
create table Users (
       name varchar(30),
       created_at integer,
       updated_at integer,
       PrimaryKey integer primary key
);

drop table if exists Rhythms;
create table Rhythms (
       name varchar(30),
       directory_name varchar(30),
       created_at integer,
       updated_at integer,
       PrimaryKey integer primary key
);

drop table if exists Levels;
create table Levels (
       name varchar(30),
       description varchar(120),
       directory_name varchar(30),
       rhythm_id integer,
       created_at integer,
       updated_at integer,
       PrimaryKey integer primary key
);

drop table if exists Stages;
create table Stages (
       name varchar(30),
       file_name varchar(30),
       level_id integer,
       created_at integer,
       updated_at integer,
       PrimaryKey integer primary key
);


drop table if exists LevelResults;
create table LevelResults (
       score integer,
       accuracy real,
       user_id integer,
       speed integer,
       level_id integer,
       rhythm_id integer,
       created_at integer,
       updated_at integer,
       PrimaryKey integer primary key
);

