create table "dbtools"."logon_filters"
("username" varchar2(30),
	 "osuser" varchar2(30),
	 "machine" varchar2(64),
	 "ipaddress" varchar2(15)
) tablespace "TSD_DBTOOLS01" storage (buffer_pool keep)
/

insert into dbtools.logon_filters(username, osuser, machine, ipaddress) values('APP%OWN', '%', '^svr[0-9]{4}$', '%');
insert into dbtools.logon_filters(username, osuser, machine, ipaddress) values('APP%OWN', '%', '^.*.adm.infra$', '%');
insert into dbtools.logon_filters(username, osuser, machine, ipaddress) values('APP%OWN', '%', '^.*.oi.infra$', '%');
insert into dbtools.logon_filters(username, osuser, machine, ipaddress) values('APP%USR', '%', '^svr[0-9]{4}$', '%');
insert into dbtools.logon_filters(username, osuser, machine, ipaddress) values('APP%USR', '%', '^.*.adm.infra$', '%');
insert into dbtools.logon_filters(username, osuser, machine, ipaddress) values('APP%USR', '%', '^.*.oi.infra$', '%');
