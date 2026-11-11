USE SmartWasteDB;
GO

-- 1. Kiem tra so luong du lieu trong cac bang
SELECT 'tblRoles' AS tableName, COUNT(*) AS total FROM dbo.tblRoles
UNION ALL
SELECT 'tblUsers', COUNT(*) FROM dbo.tblUsers
UNION ALL
SELECT 'tblAreas', COUNT(*) FROM dbo.tblAreas
UNION ALL
SELECT 'tblWasteBins', COUNT(*) FROM dbo.tblWasteBins
UNION ALL
SELECT 'tblCollectionRequests', COUNT(*) FROM dbo.tblCollectionRequests
UNION ALL
SELECT 'tblAlerts', COUNT(*) FROM dbo.tblAlerts
UNION ALL
SELECT 'tblMaintenance', COUNT(*) FROM dbo.tblMaintenance
UNION ALL
SELECT 'tblBinReadings', COUNT(*) FROM dbo.tblBinReadings;
GO

-- 2. Kiem tra roles
SELECT * FROM dbo.tblRoles;
GO

-- 3. Kiem tra tai khoan va role
SELECT
    u.userID,
    u.fullName,
    u.email,
    u.phoneNumber,
    u.roleID,
    r.roleName,
    u.status
FROM dbo.tblUsers u
LEFT JOIN dbo.tblRoles r ON u.roleID = r.roleID
ORDER BY u.roleID, u.userID;
GO

-- 4. Kiem tra khu vuc
SELECT * FROM dbo.tblAreas;
GO

-- 5. Kiem tra thung rac va khu vuc
SELECT
    b.binID,
    b.binCode,
    b.location,
    b.capacity,
    b.currentFill,
    b.status,
    b.areaID,
    a.areaName
FROM dbo.tblWasteBins b
LEFT JOIN dbo.tblAreas a ON b.areaID = a.areaID
ORDER BY b.binCode;
GO

-- 6. Thung rac co areaID khong hop le
SELECT b.*
FROM dbo.tblWasteBins b
LEFT JOIN dbo.tblAreas a ON b.areaID = a.areaID
WHERE b.areaID IS NULL OR a.areaID IS NULL;
GO

-- 7. Yeu cau thu gom
SELECT
    cr.*,
    b.binCode,
    u.fullName AS staffName
FROM dbo.tblCollectionRequests cr
LEFT JOIN dbo.tblWasteBins b ON cr.binID = b.binID
LEFT JOIN dbo.tblUsers u ON cr.staffID = u.userID
ORDER BY cr.createdDate DESC;
GO

-- 8. Canh bao
SELECT
    al.*,
    b.binCode
FROM dbo.tblAlerts al
LEFT JOIN dbo.tblWasteBins b ON al.binID = b.binID
ORDER BY al.createdDate DESC;
GO

-- 9. Bao tri
SELECT
    m.*,
    b.binCode,
    u.fullName AS technicianName
FROM dbo.tblMaintenance m
LEFT JOIN dbo.tblWasteBins b ON m.binID = b.binID
LEFT JOIN dbo.tblUsers u ON m.technicianID = u.userID
ORDER BY m.scheduledDate DESC;
GO

-- 10. Du lieu cam bien moi nhat
SELECT TOP 100
    br.readingID,
    b.binCode,
    br.fillPercent,
    br.measuredAt
FROM dbo.tblBinReadings br
LEFT JOIN dbo.tblWasteBins b ON br.binID = b.binID
ORDER BY br.measuredAt DESC;
GO

-- 11. Kiem tra role co du 5 loai khong
SELECT roleID, roleName
FROM dbo.tblRoles
WHERE roleID IN ('ADM', 'MGR', 'STF', 'TEC', 'USR');
GO

-- 12. Kiem tra tai khoan khong co role hop le
SELECT u.*
FROM dbo.tblUsers u
LEFT JOIN dbo.tblRoles r ON u.roleID = r.roleID
WHERE r.roleID IS NULL;
GO

-- 13. Kiem tra cac rang buoc va khoa ngoai
DBCC CHECKCONSTRAINTS WITH ALL_CONSTRAINTS;
GO


SELECT areaID, areaName
FROM tblAreas
ORDER BY areaID;

SELECT userID, fullName, roleID, areaID
FROM tblUsers
WHERE roleID IN ('MGR', 'STF', 'TEC')
ORDER BY roleID, userID;

SELECT
    u.userID,
    u.fullName,
    u.roleID,
    r.roleName
FROM tblUsers u
LEFT JOIN tblRoles r ON u.roleID = r.roleID
WHERE u.userID = 'staff2';

-- Kiểm tra khu vực của thùng rác
SELECT binID, binCode, location, areaID
FROM tblWasteBins
WHERE binCode LIKE '%BIN03%'
   OR binID LIKE '%BIN03%';