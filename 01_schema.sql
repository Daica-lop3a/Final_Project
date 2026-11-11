-- =====================================================================
-- SMARTWASTE DATABASE: FULL SCHEMA (8-ROLE DYNAMIC RBAC ARCHITECTURE)
-- =====================================================================
USE master;
GO
IF DB_ID(N'SmartWasteDB') IS NOT NULL
BEGIN
    ALTER DATABASE SmartWasteDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SmartWasteDB;
END;
GO
CREATE DATABASE SmartWasteDB;
GO
USE SmartWasteDB;
GO

-- --------------------------------------------------
-- TABLE: tblRoles
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRoles](
	[roleID] [varchar](10) NOT NULL,
	[roleName] [nvarchar](50) NOT NULL,
	[description] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[roleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- --------------------------------------------------
-- TABLE: tblPermissions
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPermissions](
	[permissionID] [varchar](50) NOT NULL,
	[permissionName] [nvarchar](100) NOT NULL,
	[category] [nvarchar](50) NOT NULL,
	[description] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[permissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

-- --------------------------------------------------
-- TABLE: tblRolePermissions
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRolePermissions](
	[roleID] [varchar](10) NOT NULL,
	[permissionID] [varchar](50) NOT NULL,
	[grantedDate] [datetime] NULL,
 CONSTRAINT [PK_RolePermissions] PRIMARY KEY CLUSTERED 
(
	[roleID] ASC,
	[permissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblRolePermissions] ADD  DEFAULT (getdate()) FOR [grantedDate]
GO
ALTER TABLE [dbo].[tblRolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_RolePerm_Perm] FOREIGN KEY([permissionID])
REFERENCES [dbo].[tblPermissions] ([permissionID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRolePermissions] CHECK CONSTRAINT [FK_RolePerm_Perm]
GO
ALTER TABLE [dbo].[tblRolePermissions]  WITH CHECK ADD  CONSTRAINT [FK_RolePerm_Role] FOREIGN KEY([roleID])
REFERENCES [dbo].[tblRoles] ([roleID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblRolePermissions] CHECK CONSTRAINT [FK_RolePerm_Role]
GO

-- --------------------------------------------------
-- TABLE: tblAreas
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAreas](
	[areaID] [varchar](50) NOT NULL,
	[areaName] [nvarchar](100) NOT NULL,
	[description] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[areaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblAreas]  WITH CHECK ADD  CONSTRAINT [CK_Area_ID] CHECK  (([areaID] like 'AREA-[0-9][0-9]%'))
GO
ALTER TABLE [dbo].[tblAreas] CHECK CONSTRAINT [CK_Area_ID]
GO

-- --------------------------------------------------
-- TABLE: tblUsers
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUsers](
	[userID] [varchar](50) NOT NULL,
	[fullName] [nvarchar](100) NOT NULL,
	[email] [varchar](100) NOT NULL,
	[phoneNumber] [varchar](15) NOT NULL,
	[roleID] [varchar](10) NOT NULL,
	[password] [varchar](255) NOT NULL,
	[status] [bit] NULL,
	[createdDate] [datetime] NULL,
	[areaID] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblUsers] ADD  DEFAULT ((1)) FOR [status]
GO
ALTER TABLE [dbo].[tblUsers] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblUsers]  WITH NOCHECK ADD  CONSTRAINT [FK_Users_Area] FOREIGN KEY([areaID])
REFERENCES [dbo].[tblAreas] ([areaID])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_Users_Area]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [FK_Users_Role] FOREIGN KEY([roleID])
REFERENCES [dbo].[tblRoles] ([roleID])
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [FK_Users_Role]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [CK_Users_Phone] CHECK  (([phoneNumber] like '0[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' AND len([phoneNumber])=(10) OR [phoneNumber] like '+84[35789][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' AND len([phoneNumber])=(12)))
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [CK_Users_Phone]
GO
ALTER TABLE [dbo].[tblUsers]  WITH CHECK ADD  CONSTRAINT [CK_Users_Role] CHECK  (([roleID]='USR' OR [roleID]='AUD' OR [roleID]='TEC' OR [roleID]='STF' OR [roleID]='SUP' OR [roleID]='MGR' OR [roleID]='ADM' OR [roleID]='SAD'))
GO
ALTER TABLE [dbo].[tblUsers] CHECK CONSTRAINT [CK_Users_Role]
GO

-- --------------------------------------------------
-- TABLE: tblUserAreas
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblUserAreas](
	[userID] [varchar](50) NOT NULL,
	[areaID] [varchar](50) NOT NULL,
	[assignedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[userID] ASC,
	[areaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblUserAreas] ADD  DEFAULT (getdate()) FOR [assignedDate]
GO
ALTER TABLE [dbo].[tblUserAreas]  WITH NOCHECK ADD  CONSTRAINT [FK_UserAreas_Area] FOREIGN KEY([areaID])
REFERENCES [dbo].[tblAreas] ([areaID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblUserAreas] CHECK CONSTRAINT [FK_UserAreas_Area]
GO
ALTER TABLE [dbo].[tblUserAreas]  WITH CHECK ADD  CONSTRAINT [FK_UserAreas_User] FOREIGN KEY([userID])
REFERENCES [dbo].[tblUsers] ([userID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblUserAreas] CHECK CONSTRAINT [FK_UserAreas_User]
GO

-- --------------------------------------------------
-- TABLE: tblWasteBins
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblWasteBins](
	[binID] [varchar](50) NOT NULL,
	[binCode] [varchar](50) NOT NULL,
	[location] [nvarchar](255) NOT NULL,
	[latitude] [decimal](9, 6) NOT NULL,
	[longitude] [decimal](9, 6) NOT NULL,
	[capacity] [float] NOT NULL,
	[currentFill] [float] NULL,
	[status] [nvarchar](20) NOT NULL,
	[areaID] [varchar](50) NOT NULL,
	[lastEmptied] [datetime] NULL,
	[lastUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[binID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[binCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_WasteBins_Area_Status] ON [dbo].[tblWasteBins]
(
	[areaID] ASC,
	[status] ASC,
	[currentFill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblWasteBins] ADD  DEFAULT ((0)) FOR [currentFill]
GO
ALTER TABLE [dbo].[tblWasteBins] ADD  DEFAULT (getdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[tblWasteBins]  WITH NOCHECK ADD  CONSTRAINT [FK_Bins_Area] FOREIGN KEY([areaID])
REFERENCES [dbo].[tblAreas] ([areaID])
GO
ALTER TABLE [dbo].[tblWasteBins] CHECK CONSTRAINT [FK_Bins_Area]
GO
ALTER TABLE [dbo].[tblWasteBins]  WITH CHECK ADD  CONSTRAINT [CK_Bins_Fill] CHECK  (([currentFill]>=(0) AND [currentFill]<=(100)))
GO
ALTER TABLE [dbo].[tblWasteBins] CHECK CONSTRAINT [CK_Bins_Fill]
GO
ALTER TABLE [dbo].[tblWasteBins]  WITH CHECK ADD  CONSTRAINT [CK_Bins_Status] CHECK  (([status]='Inactive' OR [status]='Full' OR [status]='Maintenance' OR [status]='Active'))
GO
ALTER TABLE [dbo].[tblWasteBins] CHECK CONSTRAINT [CK_Bins_Status]
GO

-- --------------------------------------------------
-- TABLE: tblDevices
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDevices](
	[deviceID] [varchar](50) NOT NULL,
	[deviceName] [nvarchar](100) NOT NULL,
	[deviceType] [varchar](50) NOT NULL,
	[binID] [varchar](50) NULL,
	[status] [varchar](20) NOT NULL,
	[batteryLevel] [int] NOT NULL,
	[lastPing] [datetime] NULL,
	[installedDate] [datetime] NULL,
	[firmwareVersion] [nvarchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[deviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblDevices] ADD  DEFAULT ('Active') FOR [status]
GO
ALTER TABLE [dbo].[tblDevices] ADD  DEFAULT ((100)) FOR [batteryLevel]
GO
ALTER TABLE [dbo].[tblDevices] ADD  DEFAULT (getdate()) FOR [lastPing]
GO
ALTER TABLE [dbo].[tblDevices] ADD  DEFAULT (getdate()) FOR [installedDate]
GO
ALTER TABLE [dbo].[tblDevices] ADD  DEFAULT ('v1.2.0') FOR [firmwareVersion]
GO
ALTER TABLE [dbo].[tblDevices]  WITH CHECK ADD  CONSTRAINT [FK_Devices_Bin] FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblDevices] CHECK CONSTRAINT [FK_Devices_Bin]
GO
ALTER TABLE [dbo].[tblDevices]  WITH CHECK ADD  CONSTRAINT [CK_Devices_Battery] CHECK  (([batteryLevel]>=(0) AND [batteryLevel]<=(100)))
GO
ALTER TABLE [dbo].[tblDevices] CHECK CONSTRAINT [CK_Devices_Battery]
GO
ALTER TABLE [dbo].[tblDevices]  WITH CHECK ADD  CONSTRAINT [CK_Devices_Status] CHECK  (([status]='Maintenance' OR [status]='Inactive' OR [status]='Active'))
GO
ALTER TABLE [dbo].[tblDevices] CHECK CONSTRAINT [CK_Devices_Status]
GO

-- --------------------------------------------------
-- TABLE: tblBinReadings
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBinReadings](
	[readingID] [int] IDENTITY(1,1) NOT NULL,
	[binID] [varchar](50) NOT NULL,
	[fillPercent] [int] NOT NULL,
	[temperature] [float] NULL,
	[batteryPercent] [int] NULL,
	[measuredAt] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[readingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_BinReadings_Bin_Date] ON [dbo].[tblBinReadings]
(
	[binID] ASC,
	[measuredAt] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblBinReadings] ADD  DEFAULT (getdate()) FOR [measuredAt]
GO
ALTER TABLE [dbo].[tblBinReadings]  WITH CHECK ADD  CONSTRAINT [FK_BinReadings_Bin] FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblBinReadings] CHECK CONSTRAINT [FK_BinReadings_Bin]
GO
ALTER TABLE [dbo].[tblBinReadings]  WITH CHECK ADD  CONSTRAINT [CK_BinReadings_Fill] CHECK  (([fillPercent]>=(0) AND [fillPercent]<=(100)))
GO
ALTER TABLE [dbo].[tblBinReadings] CHECK CONSTRAINT [CK_BinReadings_Fill]
GO

-- --------------------------------------------------
-- TABLE: tblBinInspections
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblBinInspections](
	[inspectionID] [varchar](50) NOT NULL,
	[binID] [varchar](50) NOT NULL,
	[inspectorID] [varchar](50) NOT NULL,
	[inspectionDate] [datetime] NULL,
	[actualFillPercent] [int] NOT NULL,
	[sensorFillPercent] [int] NOT NULL,
	[discrepancyPercent] [int] NOT NULL,
	[physicalCondition] [nvarchar](50) NOT NULL,
	[actionTaken] [nvarchar](100) NOT NULL,
	[notes] [nvarchar](500) NULL,
	[createdDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[inspectionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblBinInspections] ADD  DEFAULT (getdate()) FOR [inspectionDate]
GO
ALTER TABLE [dbo].[tblBinInspections] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblBinInspections]  WITH CHECK ADD FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
GO
ALTER TABLE [dbo].[tblBinInspections]  WITH CHECK ADD  CONSTRAINT [FK__tblBinIns__inspe__17F790F9] FOREIGN KEY([inspectorID])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblBinInspections] CHECK CONSTRAINT [FK__tblBinIns__inspe__17F790F9]
GO

-- --------------------------------------------------
-- TABLE: tblCollectionRequests
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCollectionRequests](
	[requestID] [varchar](50) NOT NULL,
	[binID] [varchar](50) NOT NULL,
	[supervisorID] [varchar](50) NULL,
	[staffID] [varchar](50) NULL,
	[status] [nvarchar](20) NOT NULL,
	[priority] [nvarchar](20) NOT NULL,
	[createdDate] [datetime] NULL,
	[completedDate] [datetime] NULL,
	[notes] [nvarchar](500) NULL,
	[startedDate] [datetime] NULL,
	[photoBefore] [nvarchar](500) NULL,
	[photoAfter] [nvarchar](500) NULL,
	[failureReason] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[requestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Collection_Staff_Status] ON [dbo].[tblCollectionRequests]
(
	[staffID] ASC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCollectionRequests] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblCollectionRequests]  WITH CHECK ADD  CONSTRAINT [FK_Req_Bin] FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
GO
ALTER TABLE [dbo].[tblCollectionRequests] CHECK CONSTRAINT [FK_Req_Bin]
GO
ALTER TABLE [dbo].[tblCollectionRequests]  WITH CHECK ADD  CONSTRAINT [FK_Req_Staff] FOREIGN KEY([staffID])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblCollectionRequests] CHECK CONSTRAINT [FK_Req_Staff]
GO
ALTER TABLE [dbo].[tblCollectionRequests]  WITH CHECK ADD  CONSTRAINT [FK_Req_Supervisor] FOREIGN KEY([supervisorID])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblCollectionRequests] CHECK CONSTRAINT [FK_Req_Supervisor]
GO
ALTER TABLE [dbo].[tblCollectionRequests]  WITH CHECK ADD  CONSTRAINT [CK_Req_Priority] CHECK  (([priority]='Emer' OR [priority]='Emergency' OR [priority]='High' OR [priority]='Normal'))
GO
ALTER TABLE [dbo].[tblCollectionRequests] CHECK CONSTRAINT [CK_Req_Priority]
GO
ALTER TABLE [dbo].[tblCollectionRequests]  WITH CHECK ADD  CONSTRAINT [CK_Req_Status] CHECK  (([status]='Cancelled' OR [status]='Skipped' OR [status]='Failed' OR [status]='Verified' OR [status]='Completed' OR [status]='In_Progress' OR [status]='Pending'))
GO
ALTER TABLE [dbo].[tblCollectionRequests] CHECK CONSTRAINT [CK_Req_Status]
GO

-- --------------------------------------------------
-- TABLE: tblMaintenance
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMaintenance](
	[maintenanceID] [varchar](50) NOT NULL,
	[binID] [varchar](50) NOT NULL,
	[technicianID] [varchar](50) NOT NULL,
	[maintenanceType] [nvarchar](50) NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[scheduledDate] [datetime] NULL,
	[completedDate] [datetime] NULL,
	[description] [nvarchar](500) NULL,
	[resolutionNotes] [nvarchar](500) NULL,
	[rootCause] [nvarchar](255) NULL,
	[repairMethod] [nvarchar](255) NULL,
	[replacedParts] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[maintenanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Maintenance_Tech_Status] ON [dbo].[tblMaintenance]
(
	[technicianID] ASC,
	[status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblMaintenance]  WITH CHECK ADD  CONSTRAINT [FK_Maintenance_Bin] FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
GO
ALTER TABLE [dbo].[tblMaintenance] CHECK CONSTRAINT [FK_Maintenance_Bin]
GO
ALTER TABLE [dbo].[tblMaintenance]  WITH CHECK ADD  CONSTRAINT [FK_Maintenance_Technician] FOREIGN KEY([technicianID])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblMaintenance] CHECK CONSTRAINT [FK_Maintenance_Technician]
GO
ALTER TABLE [dbo].[tblMaintenance]  WITH CHECK ADD  CONSTRAINT [CK_Maintenance_Status] CHECK  (([status]='Cancelled' OR [status]='Completed' OR [status]='In_Progress' OR [status]='Pending'))
GO
ALTER TABLE [dbo].[tblMaintenance] CHECK CONSTRAINT [CK_Maintenance_Status]
GO
ALTER TABLE [dbo].[tblMaintenance]  WITH CHECK ADD  CONSTRAINT [CK_Maintenance_Type] CHECK  (([maintenanceType]='Calibration' OR [maintenanceType]='Repair' OR [maintenanceType]='Inspection' OR [maintenanceType]='Replacement' OR [maintenanceType]='Sensor_Check'))
GO
ALTER TABLE [dbo].[tblMaintenance] CHECK CONSTRAINT [CK_Maintenance_Type]
GO

-- --------------------------------------------------
-- TABLE: tblAlerts
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAlerts](
	[alertID] [varchar](50) NOT NULL,
	[binID] [varchar](50) NOT NULL,
	[alertType] [nvarchar](50) NOT NULL,
	[message] [nvarchar](500) NOT NULL,
	[createdDate] [datetime] NULL,
	[isResolved] [bit] NULL,
	[resolvedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[alertID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblAlerts] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblAlerts] ADD  DEFAULT ((0)) FOR [isResolved]
GO
ALTER TABLE [dbo].[tblAlerts]  WITH CHECK ADD  CONSTRAINT [FK_Alerts_Bin] FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblAlerts] CHECK CONSTRAINT [FK_Alerts_Bin]
GO

-- --------------------------------------------------
-- TABLE: tblNotifications
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblNotifications](
	[notificationID] [int] IDENTITY(1,1) NOT NULL,
	[userID] [varchar](50) NOT NULL,
	[notifType] [varchar](30) NOT NULL,
	[refID] [varchar](50) NULL,
	[message] [nvarchar](500) NOT NULL,
	[createdDate] [datetime] NULL,
	[isRead] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[notificationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Notifications_User_Read] ON [dbo].[tblNotifications]
(
	[userID] ASC,
	[isRead] ASC,
	[createdDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblNotifications] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblNotifications] ADD  DEFAULT ((0)) FOR [isRead]
GO
ALTER TABLE [dbo].[tblNotifications]  WITH CHECK ADD  CONSTRAINT [FK_Notifications_User] FOREIGN KEY([userID])
REFERENCES [dbo].[tblUsers] ([userID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[tblNotifications] CHECK CONSTRAINT [FK_Notifications_User]
GO
ALTER TABLE [dbo].[tblNotifications]  WITH CHECK ADD  CONSTRAINT [CK_Notifications_Type] CHECK  (([notifType]='SYSTEM' OR [notifType]='CITIZEN_REPORT' OR [notifType]='COLLECTION' OR [notifType]='MAINTENANCE' OR [notifType]='ALERT'))
GO
ALTER TABLE [dbo].[tblNotifications] CHECK CONSTRAINT [CK_Notifications_Type]
GO

-- --------------------------------------------------
-- TABLE: tblCitizenReports
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCitizenReports](
	[reportID] [varchar](50) NOT NULL,
	[citizenID] [varchar](50) NOT NULL,
	[binID] [varchar](50) NULL,
	[areaID] [varchar](50) NULL,
	[reportType] [nvarchar](50) NOT NULL,
	[title] [nvarchar](200) NOT NULL,
	[description] [nvarchar](1000) NOT NULL,
	[imageURL] [nvarchar](500) NULL,
	[status] [nvarchar](20) NOT NULL,
	[createdDate] [datetime] NULL,
	[verifiedBy] [varchar](50) NULL,
	[verifiedDate] [datetime] NULL,
	[feedbackNote] [nvarchar](500) NULL,
	[latitude] [decimal](9, 6) NULL,
	[longitude] [decimal](9, 6) NULL,
	[rating] [int] NULL,
	[ratingComment] [nvarchar](500) NULL,
	[ratedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[reportID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING ON

GO
CREATE NONCLUSTERED INDEX [IX_Reports_Status_Date] ON [dbo].[tblCitizenReports]
(
	[status] ASC,
	[createdDate] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCitizenReports] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[tblCitizenReports] ADD  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[tblCitizenReports]  WITH NOCHECK ADD  CONSTRAINT [FK_Reports_Area] FOREIGN KEY([areaID])
REFERENCES [dbo].[tblAreas] ([areaID])
GO
ALTER TABLE [dbo].[tblCitizenReports] CHECK CONSTRAINT [FK_Reports_Area]
GO
ALTER TABLE [dbo].[tblCitizenReports]  WITH CHECK ADD  CONSTRAINT [FK_Reports_Bin] FOREIGN KEY([binID])
REFERENCES [dbo].[tblWasteBins] ([binID])
GO
ALTER TABLE [dbo].[tblCitizenReports] CHECK CONSTRAINT [FK_Reports_Bin]
GO
ALTER TABLE [dbo].[tblCitizenReports]  WITH CHECK ADD  CONSTRAINT [FK_Reports_Citizen] FOREIGN KEY([citizenID])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblCitizenReports] CHECK CONSTRAINT [FK_Reports_Citizen]
GO
ALTER TABLE [dbo].[tblCitizenReports]  WITH CHECK ADD  CONSTRAINT [FK_Reports_Verifier] FOREIGN KEY([verifiedBy])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblCitizenReports] CHECK CONSTRAINT [FK_Reports_Verifier]
GO
ALTER TABLE [dbo].[tblCitizenReports]  WITH CHECK ADD  CONSTRAINT [CK_Reports_Status] CHECK  (([status]='Verified' OR [status]='Pending' OR [status]='Cancelled' OR [status]='Rejected' OR [status]='Resolved' OR [status]='Assigned' OR [status]='Under Review' OR [status]='Submitted'))
GO
ALTER TABLE [dbo].[tblCitizenReports] CHECK CONSTRAINT [CK_Reports_Status]
GO
ALTER TABLE [dbo].[tblCitizenReports]  WITH CHECK ADD  CONSTRAINT [CK_Reports_Type] CHECK  (([reportType]='OTHER' OR [reportType]='DIRTY_AREA' OR [reportType]='DAMAGED_BIN' OR [reportType]='FULL_BIN'))
GO
ALTER TABLE [dbo].[tblCitizenReports] CHECK CONSTRAINT [CK_Reports_Type]
GO

-- --------------------------------------------------
-- TABLE: tblAuditLogs
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAuditLogs](
	[logID] [int] IDENTITY(1,1) NOT NULL,
	[userID] [varchar](50) NULL,
	[action] [varchar](50) NOT NULL,
	[tableName] [varchar](50) NULL,
	[recordID] [varchar](50) NULL,
	[oldValue] [nvarchar](max) NULL,
	[newValue] [nvarchar](max) NULL,
	[timestamp] [datetime] NULL,
	[ipAddress] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[logID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
CREATE NONCLUSTERED INDEX [IX_AuditLogs_Date] ON [dbo].[tblAuditLogs]
(
	[timestamp] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblAuditLogs] ADD  DEFAULT (getdate()) FOR [timestamp]
GO
ALTER TABLE [dbo].[tblAuditLogs]  WITH CHECK ADD  CONSTRAINT [FK_AuditLogs_User] FOREIGN KEY([userID])
REFERENCES [dbo].[tblUsers] ([userID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblAuditLogs] CHECK CONSTRAINT [FK_AuditLogs_User]
GO

-- --------------------------------------------------
-- TABLE: tblDiscrepancies
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDiscrepancies](
	[discrepancyID] [varchar](50) NOT NULL,
	[title] [nvarchar](255) NOT NULL,
	[discrepancyType] [nvarchar](50) NOT NULL,
	[targetEntity] [varchar](50) NOT NULL,
	[targetID] [varchar](50) NULL,
	[severity] [varchar](20) NOT NULL,
	[status] [varchar](20) NOT NULL,
	[detectedBy] [varchar](50) NOT NULL,
	[detectedDate] [datetime] NOT NULL,
	[description] [nvarchar](max) NULL,
	[investigationNotes] [nvarchar](max) NULL,
	[conclusionNotes] [nvarchar](max) NULL,
	[closedBy] [varchar](50) NULL,
	[closedDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[discrepancyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblDiscrepancies] ADD  DEFAULT ('Medium') FOR [severity]
GO
ALTER TABLE [dbo].[tblDiscrepancies] ADD  DEFAULT ('Open') FOR [status]
GO
ALTER TABLE [dbo].[tblDiscrepancies] ADD  DEFAULT (getdate()) FOR [detectedDate]
GO
ALTER TABLE [dbo].[tblDiscrepancies]  WITH CHECK ADD  CONSTRAINT [FK_Discrepancy_User] FOREIGN KEY([detectedBy])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblDiscrepancies] CHECK CONSTRAINT [FK_Discrepancy_User]
GO
ALTER TABLE [dbo].[tblDiscrepancies]  WITH CHECK ADD  CONSTRAINT [CK_Discrepancy_Severity] CHECK  (([severity]='Critical' OR [severity]='High' OR [severity]='Medium' OR [severity]='Low'))
GO
ALTER TABLE [dbo].[tblDiscrepancies] CHECK CONSTRAINT [CK_Discrepancy_Severity]
GO
ALTER TABLE [dbo].[tblDiscrepancies]  WITH CHECK ADD  CONSTRAINT [CK_Discrepancy_Status] CHECK  (([status]='Closed' OR [status]='Resolved' OR [status]='Investigating' OR [status]='Open'))
GO
ALTER TABLE [dbo].[tblDiscrepancies] CHECK CONSTRAINT [CK_Discrepancy_Status]
GO

-- --------------------------------------------------
-- TABLE: tblCatalogs
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblCatalogs](
	[catalogID] [int] IDENTITY(1,1) NOT NULL,
	[catalogType] [varchar](50) NOT NULL,
	[itemCode] [varchar](50) NOT NULL,
	[itemName] [nvarchar](100) NOT NULL,
	[description] [nvarchar](255) NULL,
	[displayOrder] [int] NOT NULL,
	[isActive] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[catalogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblCatalogs] ADD  DEFAULT ((1)) FOR [displayOrder]
GO
ALTER TABLE [dbo].[tblCatalogs] ADD  DEFAULT ((1)) FOR [isActive]
GO

-- --------------------------------------------------
-- TABLE: tblSystemConfig
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSystemConfig](
	[configKey] [varchar](50) NOT NULL,
	[configValue] [nvarchar](255) NOT NULL,
	[description] [nvarchar](500) NULL,
	[category] [varchar](50) NOT NULL,
	[updatedBy] [varchar](50) NULL,
	[lastUpdated] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[configKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblSystemConfig] ADD  DEFAULT ('SYSTEM') FOR [category]
GO
ALTER TABLE [dbo].[tblSystemConfig] ADD  DEFAULT (getdate()) FOR [lastUpdated]
GO
ALTER TABLE [dbo].[tblSystemConfig]  WITH CHECK ADD  CONSTRAINT [FK_SystemConfig_User] FOREIGN KEY([updatedBy])
REFERENCES [dbo].[tblUsers] ([userID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[tblSystemConfig] CHECK CONSTRAINT [FK_SystemConfig_User]
GO

-- --------------------------------------------------
-- TABLE: tblAdminPasswordRequests
-- --------------------------------------------------
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAdminPasswordRequests](
	[requestID] [int] IDENTITY(1,1) NOT NULL,
	[adminID] [varchar](50) NOT NULL,
	[reason] [nvarchar](500) NOT NULL,
	[status] [nvarchar](20) NOT NULL,
	[temporaryPassword] [varchar](50) NULL,
	[requestDate] [datetime] NULL,
	[resolvedBy] [varchar](50) NULL,
	[resolvedDate] [datetime] NULL,
	[resolutionNote] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[requestID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblAdminPasswordRequests] ADD  DEFAULT ('Pending') FOR [status]
GO
ALTER TABLE [dbo].[tblAdminPasswordRequests] ADD  DEFAULT (getdate()) FOR [requestDate]
GO
ALTER TABLE [dbo].[tblAdminPasswordRequests]  WITH CHECK ADD  CONSTRAINT [FK_AdminReq_Admin] FOREIGN KEY([adminID])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblAdminPasswordRequests] CHECK CONSTRAINT [FK_AdminReq_Admin]
GO
ALTER TABLE [dbo].[tblAdminPasswordRequests]  WITH CHECK ADD  CONSTRAINT [FK_AdminReq_Resolver] FOREIGN KEY([resolvedBy])
REFERENCES [dbo].[tblUsers] ([userID])
GO
ALTER TABLE [dbo].[tblAdminPasswordRequests] CHECK CONSTRAINT [FK_AdminReq_Resolver]
GO

