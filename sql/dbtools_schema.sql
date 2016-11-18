create tablespace TSD_DBTOOLS01 datafile '+DG_DATA' size 256M autoextend on next 256M maxsize 30G
/
create tablespace TSI_DBTOOLS01 datafile '+DG_DATA' size 256M autoextend on next 256M maxsize 30G
/

create profile PR_DBTOOLS  LIMIT
   SESSIONS_PER_USER          2
   CPU_PER_SESSION            UNLIMITED
   CPU_PER_CALL               UNLIMITED
   CONNECT_TIME               DEFAULT
   LOGICAL_READS_PER_SESSION  DEFAULT
   LOGICAL_READS_PER_CALL     10000
   PRIVATE_SGA                15K
   FAILED_LOGIN_ATTEMPTS      5
   COMPOSITE_LIMIT            5000000 
   PASSWORD_LIFE_TIME         UNLIMITED
/

create user dbtools identified by "DBTOOLS_P4SSW0RD" profile PR_DBTOOLS default tablespace tsd_dbtools01 account unlock
/

grant connect to dbtools
/

alter user dbtools quota unlimited on TSD_DBTOOLS01
/

alter user dbtools quota unlimited on TSI_DBTOOLS01
/

create table dbtools.logon_audit(
  logon_time date,
  sid  number,
  username varchar2(30),
  osuser varchar2(30),
  machine varchar2(64),
  hostname varchar2(64),
  ip_address varchar2(15),
  instance_name varchar2(16)
) tablespace TSD_DBTOOLS01
/

create index dbtools.logon_audit_idx01 on dbtools.logon_audit(username) tablespace TSI_DBTOOLS01
/
