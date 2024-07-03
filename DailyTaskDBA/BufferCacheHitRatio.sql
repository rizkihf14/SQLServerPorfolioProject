SELECT
    CAST((COUNT(*) * 100) AS DECIMAL(5,2)) AS BufferCacheHitRatio
FROM sys.dm_os_performance_counters
WHERE object_name = 'SQLServer:Buffer Manager'
    AND counter_name = 'Buffer cache hit ratio'
