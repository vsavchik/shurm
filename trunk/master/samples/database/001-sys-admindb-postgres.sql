  CREATE TABLE <ADMSCHEMA>.<ADMINDB_RELEASES>
   (	
	release varchar(30),
	rel_p1 integer default 0,
	rel_p2 integer default 0,
	rel_p3 integer default 0,
	rel_p4 integer default 0,
	begin_apply_time timestamp without time zone,
	end_apply_time timestamp without time zone,
	rel_status char(1)
   ) ;

  CREATE UNIQUE INDEX CONCURRENTLY <ADMSCHEMA>.<ADMINDB_RELEASES>_pk_idx ON <ADMSCHEMA>.<ADMINDB_RELEASES> (release);
  ALTER TABLE <ADMSCHEMA>.<ADMINDB_RELEASES> ADD CONSTRAINT <ADMINDB_RELEASES>_pk PRIMARY KEY USING INDEX <ADMSCHEMA>.<ADMINDB_RELEASES>_pk_idx;

  CREATE TABLE <ADMSCHEMA>.<ADMINDB_SCRIPTS>
   (	
	release varchar(30),
	schema varchar(30),
	id numeric(100,0),
	filename varchar(255),
	updatetime timestamp without time zone,
	updateuserid varchar(30),
	script_status char(1)
   );

  CREATE UNIQUE INDEX CONCURRENTLY <ADMSCHEMA>.<ADMINDB_SCRIPTS>_pk_idx ON <ADMSCHEMA>.<ADMINDB_SCRIPTS> (release, schema, id);
  ALTER TABLE <ADMSCHEMA>.<ADMINDB_SCRIPTS> ADD CONSTRAINT <ADMINDB_SCRIPTS>_pk PRIMARY KEY USING INDEX <ADMSCHEMA>.<ADMINDB_SCRIPTS>_pk_idx;
  ALTER TABLE <ADMSCHEMA>.<ADMINDB_SCRIPTS> ADD CONSTRAINT <ADMINDB_SCRIPTS>_fk FOREIGN KEY (release) REFERENCES <ADMSCHEMA>.<ADMINDB_RELEASES> (release) MATCH FULL;

grant select, update, insert, delete on <ADMSCHEMA>.<ADMINDB_RELEASES> to <SCHEMA>;
grant select, update, insert, delete on <ADMSCHEMA>.<ADMINDB_SCRIPTS> to <SCHEMA>;

