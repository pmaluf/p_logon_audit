CREATE OR REPLACE PROCEDURE "DBTOOLS"."P_LOGON_AUDIT" (param in varchar2) as
-- types
  type t_logon_audit_tab is table of dbtools.logon_audit%rowtype INDEX BY binary_integer;
  log t_logon_audit_tab;
-- variables
  crlf          varchar2(2)  := chr(13)||chr(10);
  tab          varchar2(2)  := chr(32);
  v_session_id      number       := sys_context('USERENV', 'SESSIONID');
  v_username      varchar2(30) := sys_context('USERENV', 'SESSION_USER');
  v_osuser      varchar2(30) := sys_context('USERENV', 'OS_USER');
  v_machine      varchar2(64) := sys_context('USERENV', 'HOST');
  v_ipaddress      varchar2(15) := sys_context('USERENV', 'IP_ADDRESS');
  v_hostname      varchar2(64) := sys_context('USERENV', 'SERVER_HOST');
  v_instance_name varchar2(16) := sys_context('USERENV', 'INSTANCE_NAME');
  v_check         number;
  v_rowid         varchar2(30);

-- procedure load_audit_tab
 procedure load_audit_tab as
 begin
  select *
    bulk collect into log
    from dbtools.logon_audit
   where logon_time >= sysdate-1;
 end;

-- procedure print_logon_audit
 procedure print_logon_audit as
 begin
   dbms_output.put_line(rpad('logon time',22)||
            rpad('sid',10)||
            rpad('username',30)||
            rpad('osuser',30)||
            rpad('machine',34)||
            rpad('hostname',34)||
            rpad('Instante Name',16));
   dbms_output.put_line(lpad(' ',21,'-')||
            lpad(' ',10, '-')||
            lpad(' ',30,'-')||
            lpad(' ',30, '-')||
            lpad(' ',34, '-')||
            lpad(' ',34, '-')||
            lpad(' ',16,'-'));
   for i in 1..log.count loop
    dbms_output.put_line(rpad(to_char(log(i).logon_time, 'DD/MM/YYYY hh24:mi:ss'),22)||
             rpad(log(i).sid,10)||
             rpad(nvl(log(i).username,' '),30)||
             rpad(nvl(log(i).osuser,' '),30)||
             rpad(nvl(log(i).machine,' '),34)||
             rpad(nvl(log(i).hostname,' '),34)||
             rpad(nvl(log(i).instance_name,' '),16));
   end loop;
 end;

-- procedure send_email_audit
 procedure send_email_audit as
  v_from      varchar2(80) := 'dba@ig.com';
  v_recipient      varchar2(80) := 'ld-si@oi.net.br';
  v_cc          varchar2(80) := 'ld-dbatec@oi.net.br';
  v_subject      varchar2(80) := '[Logon Audit] '||v_hostname||' - '||v_instance_name;
  v_mail_host      varchar2(30) := 'smtp.adm.infra';
  conn utl_smtp.connection;

 begin
   conn := utl_smtp.open_connection(v_mail_host);
   utl_smtp.helo(conn, v_mail_host);
   utl_smtp.mail(conn, v_from);
   utl_smtp.rcpt(conn, v_recipient);
   utl_smtp.rcpt(conn, v_cc);
   utl_smtp.open_data(conn);
   utl_smtp.write_data(conn,'date: '   || to_char(sysdate, 'dy, dd mon yyyy hh24:mi:ss') || crlf);
   utl_smtp.write_data(conn,'from: '   || v_from      || crlf );
   utl_smtp.write_data(conn,'subject: '|| v_subject   || crlf );
   utl_smtp.write_data(conn,'to: '     || v_recipient || crlf );
   utl_smtp.write_data(conn,'cc: '     || v_cc        || crlf );
   utl_smtp.write_data(conn,crlf);
   utl_smtp.write_data(conn,'Tentativa de conexao nao autorizada: '||crlf||crlf);
   utl_smtp.write_data(conn,rpad('logon time',22)||
                rpad('sid',10)||
                rpad('username',30)||
                rpad('osuser',30)||
                rpad('machine',34)||
                rpad('hostname',34)||
                rpad('Instante Name',16)||crlf);
   utl_smtp.write_data(conn,lpad(' ',21,'-')||
                lpad(' ',10, '-')||
                lpad(' ',30,'-')||
                lpad(' ',30, '-')||
                lpad(' ',34, '-')||
                lpad(' ',34, '-')||
                lpad(' ',16,'-')|| crlf);
   for i in 1..log.count loop
    utl_smtp.write_data(conn,rpad(to_char(log(i).logon_time, 'DD/MM/YYYY hh24:mi:ss'),22)||
                 rpad(log(i).sid,10)||
                 rpad(nvl(log(i).username,' '),30)||
                 rpad(nvl(log(i).osuser,' '),30)||
                 rpad(nvl(log(i).machine,' '),34)||
                 rpad(nvl(log(i).hostname,' '),34)||
                 rpad(nvl(log(i).instance_name,' '),16)|| crlf);
   end loop;
   utl_smtp.write_data(conn,crlf);
   utl_smtp.close_data(conn);
   utl_smtp.quit(conn);
  exception
  when utl_smtp.transient_error or utl_smtp.permanent_error then
    raise_application_error(-20000, 'unable to send mail: '||sqlerrm);
 end;

-- procedure p_log_user
procedure p_log_user as
begin
  if (V_SESSION_ID IS NOT NULL) then
    if (v_username not in ('SYS','SYSTEM','DELPHIX')) then
      select count(1) into v_check from dbtools.logon_filters
       where trim(upper(v_username))  like trim(upper(username))
         and nvl(v_ipaddress,0)       like trim(upper(ipaddress))
         and trim(upper(v_osuser))    like trim(upper(osuser))
         and regexp_like(v_machine, machine);
      if ( v_check = 0 ) then
        insert into dbtools.logon_audit(logon_time, sid, username, ip_address, machine, osuser, hostname, instance_name)
            values(sysdate, v_session_id, v_username, v_ipaddress, v_machine, v_osuser, v_hostname, v_instance_name);
        commit;
--        raise_application_error(-20001, 'Sorry, you are not allowed to connect with this user, your attempt will be audited.');
      end if;
    end if;
  end if;
end;

begin
 if (param = 'print') then
    load_audit_tab;
    print_logon_audit;
 elsif (param = 'email') then
    load_audit_tab;
    send_email_audit;
 elsif (param = 'log') then
   p_log_user;
 else
   null;
 END IF;
end;
/
