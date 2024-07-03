SELECT
    database_name AS [Database],
    backup_start_date AS [Backup Start],
    backup_finish_date AS [Backup Finish],
    DATEDIFF(second, backup_start_date, backup_finish_date) AS [Duration (s)],
    backup_size/1024/1024 AS [Size (MB)],
    [type] AS [Backup Type]
FROM
    msdb.dbo.backupset
WHERE
    database_name = 'YourDatabaseName' -- Specify your database name here
ORDER BY
    backup_start_date DESC;
