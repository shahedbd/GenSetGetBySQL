DECLARE @TableName sysname = 'YourTableName'
DECLARE @result varchar(max) = 'public class ' + @TableName + '
{'
SELECT
  @result = @result
  + CASE
    WHEN ColumnDesc IS NOT NULL THEN '
    /// <summary>
    /// ' + ColumnDesc + '
    /// </summary>'
    ELSE ''
  END
  + '
    public ' + ColumnType + ' ' + ColumnName + ' { get; set; }'
FROM (SELECT
  REPLACE(col.name, ' ', '_') ColumnName,
  column_id,
  CASE typ.name
    WHEN 'bigint' THEN 'long'
    WHEN 'binary' THEN 'byte[]'
    WHEN 'bit' THEN 'bool'
    WHEN 'char' THEN 'String'
    WHEN 'date' THEN 'DateTime'
    WHEN 'datetime' THEN 'DateTime'
    WHEN 'datetime2' THEN 'DateTime'
    WHEN 'datetimeoffset' THEN 'DateTimeOffset'
    WHEN 'decimal' THEN 'decimal'
    WHEN 'float' THEN 'float'
    WHEN 'image' THEN 'byte[]'
    WHEN 'int' THEN 'int'
    WHEN 'money' THEN 'decimal'
    WHEN 'nchar' THEN 'char'
    WHEN 'ntext' THEN 'string'
    WHEN 'numeric' THEN 'decimal'
    WHEN 'nvarchar' THEN 'String'
    WHEN 'real' THEN 'double'
    WHEN 'smalldatetime' THEN 'DateTime'
    WHEN 'smallint' THEN 'short'
    WHEN 'smallmoney' THEN 'decimal'
    WHEN 'text' THEN 'String'
    WHEN 'time' THEN 'TimeSpan'
    WHEN 'timestamp' THEN 'DateTime'
    WHEN 'tinyint' THEN 'byte'
    WHEN 'uniqueidentifier' THEN 'Guid'
    WHEN 'varbinary' THEN 'byte[]'
    WHEN 'varchar' THEN 'string'
    ELSE 'UNKNOWN_' + typ.name
  END + CASE
    WHEN col.is_nullable = 1 AND
      typ.name NOT IN ('binary', 'varbinary', 'image', 'text', 'ntext', 'varchar', 'nvarchar', 'char', 'nchar') THEN '?'
    ELSE ''
  END ColumnType,
  colDesc.colDesc AS ColumnDesc
FROM sys.columns col
JOIN sys.types typ
  ON col.system_type_id = typ.system_type_id
  AND col.user_type_id = typ.user_type_id
OUTER APPLY (SELECT TOP 1
  CAST(value AS nvarchar(max)) AS colDesc
FROM sys.extended_properties
WHERE major_id = col.object_id
AND minor_id = COLUMNPROPERTY(major_id, col.name, 'ColumnId')) colDesc
WHERE object_id = OBJECT_ID(@TableName)) t
ORDER BY column_id

SET @result = @result + '
}'

PRINT @result