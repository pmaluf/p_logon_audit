set serveroutput on
declare
x binary_integer;
begin
dbms_job.submit(x, 'dbtools.p_logon_audit(''email'');',sysdate,'trunc(sysdate+1)+8/24 /*Every day at 8*/');
commit;
end;
/
