SELECT
    TOP 5 total_logical_reads,
    total_logical_writes,
    total_physical_reads,
    execution_count,
    total_logical_reads + total_logical_writes AS [Aggregated I/O],
    total_elapsed_time,
    statement_start_offset,
    statement_end_offset,
    plan_handle,
    sql_handle
FROM
    sys.dm_exec_requests
ORDER BY
    [Aggregated I/O] DESC;
