create table if not exists bird(
  bid integer primary key,
  name text unique not null,
  role text not null,
  event_offset integer not null
);

create table if not exists task(
  tid integer primary key,
  created_at datatime not null
    default current_timestamp,
  status text not null
    default 'created'
    check (status in ('created', 'completed')),
  title text not null default '',
  fee integer not null,
  reward integer not null,
  assigned_to integer not null,
  foreign key(assigned_to) references bird(bid)
);

create view if not exists all_tasks as
  select * from task, bird where assigned_to = bid;
