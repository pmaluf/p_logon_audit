# p_logon_audit

This procedure will audit and disconnect any user who matches the specified rule.

## Notice

This procedure was tested in:

* Linux
  * OS Distribution: Red Hat Enterprise Linux Server release 6.5 (Santiago)
  * Oracle Database: 11gR2

## Prerequisities

* Oracle Database 11gR2

## INSTALL

* Create the dbtools schema
```
SQL> @sql/dbtools_schema.sql
```

* Create the ACL to enable dbtools user to send email
```
begin
  dbms_network_acl_admin.create_acl (
    acl          => 'acl_email_relay.xml',
    description  => 'acl for email relay',
    principal    => 'DBTOOLS',
    is_grant     => true,
    privilege    => 'connect',
    start_date   => systimestamp,
    end_date     => null);
 
  commit;
end;
/
 
begin
  dbms_network_acl_admin.assign_acl (
    acl => 'acl_email_relay.xml',
    host => 'smtp.adm.infra',
    lower_port => 25,
    upper_port => null);
end;
/
```
* Edit the variables v_from and v_mail_host in sql/p_logon_audit.sql and run it
```
SQL> @sql/p_logon_audit.sql
```
> Remove the comment at line 113 to disconnect the user

* Create trg_logon_audit trigger
```sql
create or replace trigger sys.trg_logon_audit
    after logon on database
-- declare
--  logon_denied exception;
--  pragma exception_init(logon_denied, -20001);
begin
   dbtools.p_logon_audit('log');
exception
--  when logon_denied then
--  raise_application_error(-20001, 'Sorry, you are not allowed to connect with this user.');
  when others then
   null;
end;
/
```
> Remove the comments above to disconnect the user


* Schedule the job to send an email every day at 8AM
```sql
declare
x binary_integer;
begin
dbms_job.submit(x, 'dbtools.p_logon_audit(''email'');',sysdate,'trunc(sysdate+1)+8/24 /*Every day at 8*/');
commit;
end;
/
```

## License

This project is licensed under the MIT License - see the [License.md](License.md) file for details
