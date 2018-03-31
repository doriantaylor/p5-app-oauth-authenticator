-- Emacs: -*- mode: sql; sql-product: postgres -*-

DROP TABLE IF EXISTS principal CASCADE;
CREATE TABLE principal (
  id         text                        not null,
  identified timestamp without time zone not null default now(),
  constraint pk_principal primary key (id),
  constraint ck_principal check (id = trim(id))
);

-- relates provider, principal, principal's identity on provider, access token

DROP TABLE IF EXISTS provider_state CASCADE;
CREATE TABLE provider_state (
  principal text                        not null,
  provider  varchar(255)                not null,
  userid    varchar(255)                not null,
  created   timestamp without time zone not null default now(),
  expires   timestamp without time zone not null default 'infinity'::timestamp,
  token     text                        not null,
  constraint pk_provider_state primary key (principal, provider),
  constraint uq_provider_state unique (provider, userid),
  constraint ck_provider_state check (provider = trim(lower(provider))),
  constraint fk_provider_state foreign key (principal)
    references principal (id)
);

-- relates the cookie to the principal

DROP TABLE IF EXISTS principal_state CASCADE;
CREATE TABLE principal_state (
  id        uuid                        not null,
  principal text                        not null,
  created   timestamp without time zone not null default now(),
  expires   timestamp without time zone not null default 'infinity'::timestamp,
  constraint pk_principal_state primary key (id),
  constraint uq_principal_state unique (principal),
  constraint fk_principal_state foreign key (principal)
    references principal (id)
);
