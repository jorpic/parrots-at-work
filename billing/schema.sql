create table if not exists bird(
  bid integer primary key,
  name text unique not null,
  role text not null
);

create table if not exists task(
  tid integer primary key,
  title text not null,
  jira_id text,
  fee integer not null,
  reward integer not null
);


create table if not exists balance(
  bird_id integer primary key,
  money integer not null default 0,
  foreign key(bird_id) references bird(bid)
);

create table if not exists tx(
  id integer primary key,
  created_at datetime not null default current_timestamp,
  bird_id integer not null,
  amount integer not null,
  reason json not null,
  foreign key(bird_id) references bird(bid)
);

create trigger if not exists update_balance_on_tx
  after insert on tx
  begin
    insert into balance(bird_id, money)
      values (new.bird_id, new.amount)
      on conflict (bird_id)
        do update set money = money + new.amount;
  end;
