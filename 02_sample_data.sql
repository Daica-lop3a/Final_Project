-- =====================================================================
-- SMARTWASTE DATABASE: SAMPLE DATA (8 ROLES ARCHITECTURE - FPT UNIVERSITY HCM)
-- Default password for all accounts: 123456
-- PBKDF2 Hash: 20000:50b840b0d382c96f1cf93376a2cd722b:09209ec667a85cd6b736efac4b295ff18bc25c34bd4c88639dc7a47afce0b835
-- =====================================================================

USE SmartWasteDB;
GO

SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    --------------------------------------------------
    -- 1. PURGE EXISTING DATA IN FOREIGN KEY ORDER
    --------------------------------------------------
    DELETE FROM dbo.tblAdminPasswordRequests;
    DELETE FROM dbo.tblDiscrepancies;
    DELETE FROM dbo.tblNotifications;
    DELETE FROM dbo.tblAuditLogs;
    DELETE FROM dbo.tblCitizenReports;
    DELETE FROM dbo.tblAlerts;
    DELETE FROM dbo.tblMaintenance;
    DELETE FROM dbo.tblCollectionRequests;
    DELETE FROM dbo.tblBinReadings;
    DELETE FROM dbo.tblBinInspections;
    DELETE FROM dbo.tblDevices;
    DELETE FROM dbo.tblWasteBins;
    DELETE FROM dbo.tblUserAreas;
    DELETE FROM dbo.tblUsers;
    DELETE FROM dbo.tblAreas;
    DELETE FROM dbo.tblRoles;

    --------------------------------------------------
    -- 2. INSERT 8 ROLES
    --------------------------------------------------
    INSERT INTO dbo.tblRoles (roleID, roleName, description)
    VALUES
    ('SAD', 'Super Admin', 'Highest system authority, master administration, and full audit trail access'),
    ('ADM', 'System Admin', 'System operations, employee account management, and infrastructure configuration'),
    ('MGR', 'Operations Manager', 'Oversees waste collection logistics, monitors fill levels across multiple zones'),
    ('SUP', 'Area Supervisor', 'Supervises assigned zones, dispatches collection tasks, verifies citizen reports'),
    ('STF', 'Collection Staff', 'Performs on-ground waste pickup, confirms collections, updates bin status'),
    ('TEC', 'IoT Technician', 'Maintains hardware sensors, tests IoT telemetry, records calibration reports'),
    ('AUD', 'System Auditor', 'Read-only compliance auditor, reviews audit trails, operations, and discrepancy logs'),
    ('USR', 'Citizen User', 'Public citizen, locates smart bins on live map, submits waste & damage reports');

    --------------------------------------------------
    -- 3. INSERT 5 FLOORS / AREAS OF FPT UNIVERSITY HCM (STRICTLY INDOOR CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblAreas (areaID, areaName, description)
    VALUES
    ('AREA-00', 'Ground Floor (Floor G) - Trong Dong Lobby, Library & Labs', 'Main entrance Trong Dong lobby, Central Library Ground Floor, Ohm Lab, and Lecture Rooms 001 - 045'),
    ('AREA-01', '1st Floor (Floor 1) - Lecture Halls, Main Library & Culture Lab', 'Theory lecture halls 101 - 137, Library 1st Floor Atrium, IT Helpdesk, and Culture Lab'),
    ('AREA-02', '2nd Floor (Floor 2) - Lecture Halls, Student Services & Skills Hub', 'Classrooms 203 - 234, Student Services Office (DVSV 202), and Art & Writing Hub 1'),
    ('AREA-03', '3rd Floor (Floor 3) - Little UK English Zone & Lecture Halls', 'Little UK (LUK) International English Zone, Classrooms 301 - 315, and Hall Business 3rd Floor'),
    ('AREA-04', '4th Floor (Floor 4) - Grand Auditory Halls & Executive Classrooms', 'Academic Hall, Hall C, Business Hall 4th Floor, and Classrooms 404 - 422');

    --------------------------------------------------
    -- 4. INSERT USERS (8 DEMO ACCOUNTS REPRESENTING 8 ROLES)
    -- All accounts have password: 123456
    --------------------------------------------------
    DECLARE @pwd VARCHAR(255) = '20000:50b840b0d382c96f1cf93376a2cd722b:09209ec667a85cd6b736efac4b295ff18bc25c34bd4c88639dc7a47afce0b835';

    INSERT INTO dbo.tblUsers (userID, fullName, email, phoneNumber, roleID, password, status, areaID)
    VALUES
    ('superadmin', 'Tran Dai Nam',   'superadmin@smartwaste.com', '0901000000', 'SAD', @pwd, 1, NULL),
    ('admin1',     'Nguyen Van An',  'admin@smartwaste.com',      '0901000001', 'ADM', @pwd, 1, NULL),
    ('mgr1',       'Tran Thi Binh',  'manager@smartwaste.com',    '0901000002', 'MGR', @pwd, 1, 'AREA-00'),
    ('sup1',       'Le Hoang Son',   'supervisor@smartwaste.com', '0901000003', 'SUP', @pwd, 1, 'AREA-00'),
    ('staff1',     'Pham Van Cuong', 'staff1@smartwaste.com',     '0901000004', 'STF', @pwd, 1, 'AREA-00'),
    ('staff2',     'Hoang Thi Dung', 'staff2@smartwaste.com',     '0901000005', 'STF', @pwd, 1, 'AREA-01'),
    ('tech1',      'Vu Minh Tuan',   'tech1@smartwaste.com',      '0901000006', 'TEC', @pwd, 1, 'AREA-00'),
    ('auditor1',   'Dang Quoc Hung', 'auditor@smartwaste.com',    '0901000007', 'AUD', @pwd, 1, NULL),
    ('user1',      'Ngo Hai Yen',    'user1@smartwaste.com',      '0901000008', 'USR', @pwd, 1, 'AREA-00'),
    ('user2',      'Bui Quang Huy',  'user2@smartwaste.com',      '0901000009', 'USR', @pwd, 1, 'AREA-02');

    --------------------------------------------------
    -- 5. ZONE ALLOCATIONS (USER_AREAS)
    --------------------------------------------------
    -- Manager oversees all floors
    INSERT INTO dbo.tblUserAreas (userID, areaID) VALUES
    ('mgr1', 'AREA-00'),
    ('mgr1', 'AREA-01'),
    ('mgr1', 'AREA-02'),
    ('mgr1', 'AREA-03'),
    ('mgr1', 'AREA-04'),
    -- Supervisor sup1 supervises Floors G, 1, 2
    ('sup1', 'AREA-00'),
    ('sup1', 'AREA-01'),
    ('sup1', 'AREA-02');

    --------------------------------------------------
    -- 6. SMART WASTE BINS (12 BINS STRICTLY INDOOR CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblWasteBins (binID, binCode, location, latitude, longitude, capacity, currentFill, status, areaID, lastEmptied)
    VALUES
    -- FLOOR G (AREA-00)
    ('BIN-001', 'BIN-G-01', 'Trong Dong Main Lobby - Rooms 001 - 004 (Floor G)',                 10.841450, 106.810150, 120.0, 35.0, 'Active', 'AREA-00', DATEADD(HOUR, -12, GETDATE())),
    ('BIN-002', 'BIN-G-02', 'Ground Floor Library - Main Study Hall & Rooms 040 - 044 (Floor G)', 10.841350, 106.809950, 240.0, 95.0, 'Full',   'AREA-00', DATEADD(HOUR, -36, GETDATE())),
    ('BIN-003', 'BIN-G-03', 'Ohm Lab & Innovation Corridor - Rooms 010 - 016 (Floor G)',         10.841580, 106.810250, 120.0, 25.0, 'Active', 'AREA-00', DATEADD(HOUR, -8, GETDATE())),

    -- FLOOR 1 (AREA-01)
    ('BIN-004', 'BIN-1-01', 'IT Helpdesk & Lecture Rooms Corridor 101 - 107 (Floor 1)',           10.841280, 106.810050, 240.0, 42.0, 'Active', 'AREA-01', DATEADD(HOUR, -10, GETDATE())),
    ('BIN-005', 'BIN-1-02', '1st Floor Library Atrium & Culture Lab (Floor 1)',                   10.841380, 106.810350, 120.0, 60.0, 'Active', 'AREA-01', DATEADD(HOUR, -18, GETDATE())),
    ('BIN-006', 'BIN-1-03', 'North Lecture Rooms Corridor 125 - 137 & Restrooms (Floor 1)',       10.841520, 106.809920, 120.0, 88.0, 'Full',   'AREA-01', DATEADD(HOUR, -28, GETDATE())),

    -- FLOOR 2 (AREA-02)
    ('BIN-007', 'BIN-2-01', 'Student Services Office (DVSV 202) & Rooms 203 - 206 (Floor 2)',    10.841320, 106.810100, 120.0, 15.0, 'Active', 'AREA-02', DATEADD(HOUR, -5, GETDATE())),
    ('BIN-008', 'BIN-2-02', 'Art & Writing Hub 1 & Lecture Corridor 211 - 224 (Floor 2)',         10.841480, 106.810280, 240.0, 92.0, 'Full',   'AREA-02', DATEADD(HOUR, -20, GETDATE())),

    -- FLOOR 3 (AREA-03)
    ('BIN-009', 'BIN-3-01', 'Little UK (LUK) International English Zone Lobby (Floor 3)',         10.841360, 106.809980, 240.0, 50.0, 'Active', 'AREA-03', DATEADD(HOUR, -15, GETDATE())),
    ('BIN-010', 'BIN-3-02', 'Hall Business Entrance & Lecture Rooms 301 - 305 (Floor 3)',         10.841500, 106.810180, 120.0, 30.0, 'Active', 'AREA-03', DATEADD(HOUR, -16, GETDATE())),

    -- FLOOR 4 (AREA-04)
    ('BIN-011', 'BIN-4-01', 'Grand Academic Hall & Hall C Main Portal (Floor 4)',                 10.841420, 106.810080, 240.0, 85.0, 'Full',   'AREA-04', DATEADD(HOUR, -22, GETDATE())),
    ('BIN-012', 'BIN-4-02', 'Hall Business 4th Floor & Lecture Corridor 407 - 415 (Floor 4)',     10.841550, 106.810220, 120.0, 20.0, 'Active', 'AREA-04', DATEADD(HOUR, -6, GETDATE()));

    --------------------------------------------------
    -- 7. IOT SENSOR READINGS (BIN READINGS)
    --------------------------------------------------
    INSERT INTO dbo.tblBinReadings (binID, fillPercent, temperature, batteryPercent, measuredAt)
    VALUES
    ('BIN-001', 20, 26.5, 95, DATEADD(HOUR, -4, GETDATE())),
    ('BIN-001', 35, 27.0, 94, DATEADD(MINUTE, -15, GETDATE())),
    ('BIN-002', 90, 31.0, 76, DATEADD(HOUR, -1, GETDATE())),
    ('BIN-002', 95, 31.8, 75, DATEADD(MINUTE, -5, GETDATE())),
    ('BIN-003', 25, 25.5, 92, DATEADD(HOUR, -2, GETDATE())),
    ('BIN-004', 42, 27.2, 88, DATEADD(HOUR, -3, GETDATE())),
    ('BIN-006', 88, 29.0, 80, DATEADD(MINUTE, -30, GETDATE())),
    ('BIN-008', 92, 33.2, 70, DATEADD(MINUTE, -20, GETDATE())),
    ('BIN-011', 85, 30.5, 78, DATEADD(MINUTE, -12, GETDATE()));

    --------------------------------------------------
    -- 8. COLLECTION REQUESTS (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblCollectionRequests (requestID, binID, supervisorID, staffID, status, priority, createdDate, notes)
    VALUES
    ('REQ-001', 'BIN-002', 'sup1', 'staff1', 'Pending',     'High',      DATEADD(HOUR, -1, GETDATE()), 'Ground Floor Library bin reached 95% capacity, urgent collection required before peak hours'),
    ('REQ-002', 'BIN-006', 'sup1', 'staff2', 'In_Progress', 'Normal',    DATEADD(HOUR, -2, GETDATE()), 'High waste volume observed near Floor 1 North Corridor 125 - 137, collection in progress'),
    ('REQ-003', 'BIN-008', 'sup1', 'staff1', 'Completed',   'Emergency', DATEADD(DAY, -1, GETDATE()), 'Floor 2 Art & Writing Hub waste collected successfully');

    --------------------------------------------------
    -- 9. MAINTENANCE SCHEDULES (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblMaintenance (maintenanceID, binID, technicianID, maintenanceType, status, scheduledDate, description)
    VALUES
    ('MAINT-001', 'BIN-008', 'tech1', 'Sensor_Check', 'In_Progress', GETDATE(), 'Ultrasonic distance sensor at Art & Writing Hub 1 experiencing intermittent signal loss'),
    ('MAINT-002', 'BIN-002', 'tech1', 'Inspection',   'Pending',     DATEADD(DAY, 1, GETDATE()), 'Routine quarterly inspection of bin hinges and sensor unit at Ground Floor Library');

    --------------------------------------------------
    -- 10. SYSTEM ALERTS (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblAlerts (alertID, binID, alertType, message, createdDate, isResolved)
    VALUES
    ('ALT-001', 'BIN-002', 'Overflow',     'Waste Bin BIN-G-02 (Ground Floor Library) exceeded 90% fill capacity threshold!', DATEADD(HOUR, -1, GETDATE()), 0),
    ('ALT-002', 'BIN-008', 'Overflow',     'Waste Bin BIN-2-02 (Floor 2 Art & Writing Hub) exceeded 90% fill capacity threshold!', DATEADD(MINUTE, -20, GETDATE()), 0),
    ('ALT-003', 'BIN-006', 'Overflow',     'Waste Bin BIN-1-03 (North Corridor 125-137) exceeded 85% fill capacity threshold!', DATEADD(HOUR, -3, GETDATE()), 0);

    --------------------------------------------------
    -- 11. CITIZEN REPORTS (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblCitizenReports (reportID, citizenID, binID, areaID, reportType, title, description, status, createdDate, verifiedBy, verifiedDate, feedbackNote)
    VALUES
    ('REP-001', 'user1', 'BIN-002', 'AREA-00', 'FULL_BIN',    'Overflowing bin at Ground Floor Library study area', 'Multiple discarded paper cups and study waste overflowing onto tables', 'Verified', DATEADD(HOUR, -2, GETDATE()), 'sup1', DATEADD(HOUR, -1, GETDATE()), 'Verified on site by supervisor. Collection task REQ-001 created and dispatched to staff'),
    ('REP-002', 'user2', 'BIN-007', 'AREA-02', 'DAMAGED_BIN', 'Foot pedal mechanism jammed on DVSV 202 bin', 'Foot pedal is stuck and students cannot open the bin lid hands-free', 'Pending', DATEADD(MINUTE, -45, GETDATE()), NULL, NULL, NULL);

    --------------------------------------------------
    -- 12. AUDIT LOGS (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblAuditLogs (userID, action, tableName, recordID, oldValue, newValue, timestamp, ipAddress)
    VALUES
    ('superadmin', 'LOGIN',         NULL,                    NULL,      NULL,              'User logged in successfully',                                    DATEADD(HOUR, -6, GETDATE()), '127.0.0.1'),
    ('admin1',     'CREATE_BIN',    'tblWasteBins',          'BIN-012', NULL,              'Created new waste bin at Floor 4 Hall Business corridor',        DATEADD(HOUR, -5, GETDATE()), '192.168.1.15'),
    ('sup1',       'DISPATCH_TASK', 'tblCollectionRequests', 'REQ-001', NULL,              'Dispatched collection task REQ-001 for Floor G library to staff1',DATEADD(HOUR, -1, GETDATE()), '192.168.1.22'),
    ('sup1',       'VERIFY_REPORT', 'tblCitizenReports',     'REP-001', 'status=Pending',  'status=Verified',                                                DATEADD(HOUR, -1, GETDATE()), '192.168.1.22');

    --------------------------------------------------
    -- 13. USER NOTIFICATIONS (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblNotifications (userID, notifType, refID, message, createdDate, isRead)
    VALUES
    ('staff1', 'COLLECTION',     'REQ-001',   'You have been assigned a high-priority collection task at Ground Floor Library (BIN-G-02)', DATEADD(HOUR, -1, GETDATE()), 0),
    ('tech1',  'MAINTENANCE',    'MAINT-001', 'Sensor maintenance inspection scheduled for Art & Writing Hub 1 (BIN-2-02)', DATEADD(HOUR, -3, GETDATE()), 0),
    ('user1',  'CITIZEN_REPORT', 'REP-001',   'Your report regarding the Ground Floor Library bin has been verified by the supervisor.', DATEADD(HOUR, -1, GETDATE()), 0);

    --------------------------------------------------
    -- 14. DEVICES (IOT SENSORS FOR 12 INSIDE BINS - FULL ENGLISH)
    --------------------------------------------------
    INSERT INTO dbo.tblDevices (deviceID, deviceName, deviceType, binID, status, batteryLevel, lastPing, installedDate, firmwareVersion) VALUES 
    ('DEV-001', 'Ultrasonic Sensor (Trong Dong Lobby Floor G)', 'Ultrasonic Fill Sensor', 'BIN-001', 'Active', 92, GETDATE(), '2026-09-01', 'v1.2.0'),
    ('DEV-002', 'Ultrasonic Sensor (Library Floor G)', 'Ultrasonic Fill Sensor', 'BIN-002', 'Active', 75, GETDATE(), '2026-09-01', 'v1.2.0'),
    ('DEV-003', 'Optical Sensor (Ohm Lab Floor G)', 'Optical Infrared Sensor', 'BIN-003', 'Active', 95, GETDATE(), '2026-09-05', 'v1.2.0'),
    ('DEV-004', 'Ultrasonic Sensor (IT Helpdesk Floor 1)', 'Ultrasonic Fill Sensor', 'BIN-004', 'Active', 65, GETDATE(), '2026-09-10', 'v1.2.0'),
    ('DEV-005', 'Ultrasonic Sensor (Culture Lab Floor 1)', 'Ultrasonic Fill Sensor', 'BIN-005', 'Active', 84, GETDATE(), '2026-09-15', 'v1.2.0'),
    ('DEV-006', 'Weight Load Cell (Rooms 125-137 Floor 1)', 'Weight Load Cell', 'BIN-006', 'Active', 80, GETDATE(), '2026-09-10', 'v1.2.0'),
    ('DEV-007', 'GPS & LoRaWAN Gateway (DVSV 202 Floor 2)', 'GPS & LoRaWAN Gateway', 'BIN-007', 'Active', 90, GETDATE(), '2026-09-15', 'v1.2.0'),
    ('DEV-008', 'Ultrasonic Sensor (Art & Writing Hub Floor 2)', 'Ultrasonic Fill Sensor', 'BIN-008', 'Active', 85, GETDATE(), '2026-09-20', 'v1.2.0'),
    ('DEV-009', 'Ultrasonic Sensor (Little UK Floor 3)', 'Ultrasonic Fill Sensor', 'BIN-009', 'Active', 88, GETDATE(), '2026-10-05', 'v1.2.0'),
    ('DEV-010', 'Ultrasonic Sensor (Hall Business Floor 3)', 'Ultrasonic Fill Sensor', 'BIN-010', 'Active', 79, GETDATE(), '2026-10-10', 'v1.2.0'),
    ('DEV-011', 'Ultrasonic Sensor (Academic Hall Floor 4)', 'Ultrasonic Fill Sensor', 'BIN-011', 'Active', 91, GETDATE(), '2026-10-12', 'v1.2.0'),
    ('DEV-012', 'Ultrasonic Sensor (Hall Business Floor 4)', 'Ultrasonic Fill Sensor', 'BIN-012', 'Active', 82, GETDATE(), '2026-10-15', 'v1.2.0');

    --------------------------------------------------
    -- 15. INSPECTIONS (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblBinInspections (inspectionID, binID, inspectorID, inspectionDate, actualFillPercent, sensorFillPercent, discrepancyPercent, physicalCondition, actionTaken, notes, createdDate)
    VALUES
    ('INSP-001', 'BIN-001', 'sup1', GETDATE(), 75, 70, 5, 'Good', 'None', 'Routine inspection at Trong Dong Lobby, bin lid and sensor mechanics intact.', GETDATE()),
    ('INSP-002', 'BIN-002', 'sup1', GETDATE(), 90, 45, 45, 'Sensor_Obstructed', 'Cleaned_Sensor', 'Sensor optical lens obstructed by plastic wrap, cleaned and recalibrated.', GETDATE()),
    ('INSP-003', 'BIN-008', 'sup1', GETDATE(), 92, 90, 2, 'Good', 'None', 'Physical inspection at Art & Writing Hub 1 confirms high fill level.', GETDATE());

    --------------------------------------------------
    -- 16. DISCREPANCIES (FULL ENGLISH - INSIDE CAMPUS)
    --------------------------------------------------
    INSERT INTO dbo.tblDiscrepancies (discrepancyID, title, discrepancyType, targetEntity, targetID, severity, status, detectedBy, detectedDate, description, investigationNotes, conclusionNotes, closedBy, closedDate) VALUES 
    ('DISC-001', 'Deviant Inspection Sensor Data on BIN-002', 'Inspection Deviation', 'tblBinInspections', 'INSP-002', 'High', 'Closed', 'auditor1', GETDATE(), 'Physical inspection measured 40pct while IoT sensor reported 85pct.', 'Cross-checked telemetry timestamps.', 'Sensor recalibrated. Case closed.', 'auditor1', GETDATE());

    COMMIT TRANSACTION;
    PRINT '==> FPT UNIVERSITY HCM: STRICTLY INDOOR CAMPUS DATA INITIALIZED SUCCESSFULLY! <==';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@errMsg, 16, 1);
END CATCH;
GO

-- ==================================================
-- 17. CATALOGS
-- ==================================================
IF NOT EXISTS (SELECT 1 FROM dbo.tblCatalogs)
BEGIN
    SET IDENTITY_INSERT dbo.tblCatalogs ON;
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (1, 'BIN_STATUS', 'Active', 'Active', 'Bin is operational and monitored in live system', 1, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (2, 'BIN_STATUS', 'Maintenance', 'Maintenance', 'Bin undergoing structural or sensor repair', 2, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (3, 'BIN_STATUS', 'Full', 'Full', 'Bin fill level exceeded threshold and awaits collection', 3, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (4, 'BIN_STATUS', 'Inactive', 'Inactive', 'Bin decommissioned or out of campus service', 4, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (5, 'BIN_TYPE', 'GENERAL', 'General Waste', 'Non-recyclable municipal and campus daily waste', 1, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (6, 'BIN_TYPE', 'RECYCLE', 'Recyclable Plastic & Paper', 'Sorted recyclable materials, paper, bottles and cans', 2, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (7, 'BIN_TYPE', 'ORGANIC', 'Organic & Food Waste', 'Biodegradable cafeteria and garden waste', 3, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (8, 'BIN_TYPE', 'EWASTE', 'Electronic & Battery Waste', 'Hazardous e-waste, lithium batteries and accessories', 4, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (9, 'DEVICE_TYPE', 'ULTRASONIC', 'Ultrasonic Fill Sensor', 'HC-SR04 / IP67 ultrasonic distance level sensor', 1, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (10, 'DEVICE_TYPE', 'OPTICAL', 'Optical Infrared Sensor', 'Infrared proximity and opacity measurement sensor', 2, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (11, 'DEVICE_TYPE', 'WEIGHT', 'Weight Load Cell', 'Strain-gauge compression weight measuring unit', 3, 1);
    INSERT INTO dbo.tblCatalogs (catalogID, catalogType, itemCode, itemName, description, displayOrder, isActive) VALUES (12, 'DEVICE_TYPE', 'GPS_LORA', 'GPS & LoRaWAN Gateway', 'Long-range telemetry transceiver with GPS beacon', 4, 1);
    SET IDENTITY_INSERT dbo.tblCatalogs OFF;
END
GO

-- ==================================================
-- 18. SYSTEM CONFIG
-- ==================================================
IF NOT EXISTS (SELECT 1 FROM dbo.tblSystemConfig)
BEGIN
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('AUTO_DISPATCH_COLLECTION', 'true', 'Automatically trigger collection dispatch when bin fill level exceeds overflow threshold', 'SYSTEM', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('BATTERY_LOW_THRESHOLD', '20', 'IoT sensor battery percentage (%) triggering low battery warning alerts', 'IOT_SENSOR', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('BIN_OVERFLOW_THRESHOLD', '85', 'Fill level percentage (%) triggering overflow alert and emergency collection request', 'IOT_SENSOR', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('BIN_WARNING_THRESHOLD', '60', 'Fill level percentage (%) marking bin at warning capacity threshold', 'IOT_SENSOR', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('HIGH_TEMP_THRESHOLD', '50.0', 'Internal temperature (deg C) threshold indicating fire risk inside waste bin', 'IOT_SENSOR', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('MAX_FAILED_LOGINS', '5', 'Maximum consecutive failed login attempts before account is locked', 'SECURITY', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('SENSOR_POLL_INTERVAL', '60', 'IoT telemetry polling and synchronization cycle in seconds', 'IOT_SENSOR', NULL, GETDATE());
    INSERT INTO dbo.tblSystemConfig (configKey, configValue, description, category, updatedBy, lastUpdated) VALUES ('SESSION_TIMEOUT_MINUTES', '30', 'User web session expiration timeout duration in minutes', 'SECURITY', NULL, GETDATE());
END
GO

-- ==================================================
-- 19. PERMISSIONS CATALOG & ROLE ASSIGNMENTS
-- ==================================================
MERGE dbo.tblPermissions AS target
USING (VALUES
    ('USER_MGMT',           'User Account Administration',        'Identity & Access', 'Create, edit, lock, reset credentials, and view system users'),
    ('AREA_MGMT',           'Campus Zone & Area Management',      'Infrastructure',    'Configure campus zones, geographical boundaries, and collection areas'),
    ('BIN_MANAGE',          'Smart Waste Bin Operations',         'Infrastructure',    'Deploy, configure, update status, and manage physical waste bins'),
    ('COLLECTION_DISPATCH', 'Collection Dispatch & Scheduling',   'Operations',        'Create collection tasks, assign staff, and verify route schedules'),
    ('COLLECTION_EXECUTE',  'Collection Pickup Execution',        'Operations',        'Execute on-ground collection, update pickup status, and QR check-in'),
    ('INSPECTION_MGMT',     'Physical Bin Audits & Inspections',  'Operations',        'Conduct on-site manual bin checks and record physical inspection logs'),
    ('MAINTENANCE_MGMT',    'Hardware Repairs & Maintenance',     'IoT & Hardware',    'Log maintenance tickets, repair bin mechanics, and log fixes'),
    ('DEVICE_MGMT',         'IoT Sensors & Gateway Catalogs',     'IoT & Hardware',    'Register IoT sensor hardware, configure firmware, and bin bindings'),
    ('CITIZEN_REPORTS',     'Citizen Reports & Community Feedback','Citizen & Public',  'Submit, verify, update, and resolve citizen overflow reports'),
    ('ALERT_MGMT',          'Telemetry Alerts & Thresholds',      'Operations',        'Monitor real-time sensor alerts, overflow triggers, and resolution'),
    ('ANALYTICS_EXPORT',    'Analytics Dashboard & Data Export',  'Reporting',         'View collection charts, export operational reports and audit metrics'),
    ('AUDIT_LOGS',          'Security Audit Logs Trail',          'Security & Audit',  'Access immutable system audit trail and track security events'),
    ('DISCREPANCY_AUDIT',   'Data Discrepancy & Quality Scanner', 'Security & Audit',  'Audit IoT sensor discrepancies and run data quality scans'),
    ('SYSTEM_CONFIG',       'System Rules & Master Governance',   'Governance',        'Configure system threshold parameters, backups, and role permissions')
) AS source (permissionID, permissionName, category, description)
ON target.permissionID = source.permissionID
WHEN MATCHED THEN
    UPDATE SET target.permissionName = source.permissionName,
               target.category = source.category,
               target.description = source.description
WHEN NOT MATCHED THEN
    INSERT (permissionID, permissionName, category, description)
    VALUES (source.permissionID, source.permissionName, source.category, source.description);
GO

DELETE FROM dbo.tblRolePermissions;
GO

INSERT INTO dbo.tblRolePermissions (roleID, permissionID)
SELECT 'SAD', permissionID FROM dbo.tblPermissions;

INSERT INTO dbo.tblRolePermissions (roleID, permissionID)
SELECT 'ADM', permissionID FROM dbo.tblPermissions WHERE permissionID <> 'SYSTEM_CONFIG';

INSERT INTO dbo.tblRolePermissions (roleID, permissionID) VALUES
('MGR', 'AREA_MGMT'),
('MGR', 'BIN_MANAGE'),
('MGR', 'COLLECTION_DISPATCH'),
('MGR', 'COLLECTION_EXECUTE'),
('MGR', 'INSPECTION_MGMT'),
('MGR', 'MAINTENANCE_MGMT'),
('MGR', 'CITIZEN_REPORTS'),
('MGR', 'ALERT_MGMT'),
('MGR', 'ANALYTICS_EXPORT'),
('SUP', 'BIN_MANAGE'),
('SUP', 'COLLECTION_DISPATCH'),
('SUP', 'COLLECTION_EXECUTE'),
('SUP', 'INSPECTION_MGMT'),
('SUP', 'MAINTENANCE_MGMT'),
('SUP', 'CITIZEN_REPORTS'),
('SUP', 'ALERT_MGMT'),
('SUP', 'ANALYTICS_EXPORT'),
('STF', 'COLLECTION_EXECUTE'),
('STF', 'INSPECTION_MGMT'),
('STF', 'MAINTENANCE_MGMT'),
('STF', 'CITIZEN_REPORTS'),
('TEC', 'BIN_MANAGE'),
('TEC', 'INSPECTION_MGMT'),
('TEC', 'MAINTENANCE_MGMT'),
('TEC', 'DEVICE_MGMT'),
('AUD', 'ANALYTICS_EXPORT'),
('AUD', 'AUDIT_LOGS'),
('AUD', 'DISCREPANCY_AUDIT'),
('USR', 'CITIZEN_REPORTS');
GO
