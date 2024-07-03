SELECT
    blocked_session_id,
    blocking_session_id,
    wait_type,
    wait_duration_ms,
    resource_description,
    (SELECT text FROM sys.dm_exec_sql_text(sql_handle)) AS sql_text
FROM
    sys.dm_os_waiting_tasks
WHERE
    blocking_session_id IS NOT NULL;
