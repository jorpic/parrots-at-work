create table if not exists bird(
  bid integer primary key,
  name text unique not null,
  role text not null
);
