SELECT
    database_name AS [Database],
    MAX(backup_start_date) AS [Last Backup Time],
    DATEDIFF(hour, MAX(backup_start_date), GETDATE()) AS [Hours Since Last Backup],
    backup_size/1024/1024 AS [Backup Size (MB)]
FROM
    msdb.dbo.backupset
GROUP BY
    database_name,
    backup_size
HAVING
    MAX(backup_start_date) IS NOT NULL
ORDER BY
    MAX(backup_start_date) DESC;
