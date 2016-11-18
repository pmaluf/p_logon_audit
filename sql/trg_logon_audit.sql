create or replace trigger sys.trg_logon_audit after logon on database
-- declare
--   logon_denied exception;
--   pragma exception_init(logon_denied, -20001);
begin
   dbtools.p_logon_audit('log');
exception
-- when logon_denied then
--   raise_application_error(-20001, 'Sorry, you are not allowed to connect with this user.');
  when others then
   null;
end;
/
