SELECT
    at.transaction_id,
    at.name AS transaction_name,
    at.transaction_begin_time,
    at.transaction_state,
    at.transaction_status,
    tl.request_session_id,
    tl.resource_type,
    tl.resource_database_id,
    tl.resource_description,
    tl.request_mode,
    tl.request_status
FROM
    sys.dm_tran_active_transactions at
JOIN
    sys.dm_tran_locks tl ON at.transaction_id = tl.request_owner_id;
