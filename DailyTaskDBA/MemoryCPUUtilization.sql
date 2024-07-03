SELECT
    SQLProcessUtilization AS [SQL Server Process CPU Utilization],
    SystemIdle AS [System Idle Process],
    100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization]
FROM
    (SELECT
         record_id,
         dateadd(ms, -1 * ((sys.ms_ticks / 1000) - [timestamp]), GetDate()) as [Event Time],
         SQLProcessUtilization,
         SystemIdle
     FROM
         (SELECT
              record_id,
              sys.ms_ticks,
              [timestamp],
              convert(xml, record) as [record]
          FROM sys.dm_os_ring_buffers
          CROSS JOIN sys.dm_os_sys_info sys
          WHERE ring_buffer_id = 1
          AND record_id > (SELECT MAX(record_id) FROM sys.dm_os_ring_buffers WHERE ring_buffer_id = 1) - 60
         ) AS x
     ) AS y
ORDER BY record_id DESC;
