<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.CatalogItem"%>
<%@page import="model.AppUser"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
    String ctx = request.getContextPath();
    List<CatalogItem> list = (List<CatalogItem>) request.getAttribute("CATALOG_LIST");
    String filterType = (String) request.getAttribute("FILTER_TYPE");
    String msg = request.getParameter("msg");
    AppUser currentUser = (AppUser) session.getAttribute("user");
    boolean canManage = currentUser != null && (currentUser.isSuperAdmin() || currentUser.isAdmin());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Catalogs &amp; Classifications - SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <style>
        .catalog-page {
            margin-left: 0;
            width: 100%;
            min-height: 100vh;
            padding: 34px 40px;
            box-sizing: border-box;
            background: #EDF8F2;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #1C1E21;
        }

        .header-box {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
        }

        .page-kicker {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.4px;
            text-transform: uppercase;
            color: #00875A;
            margin-bottom: 6px;
        }

        .page-title {
            margin: 0;
            font-size: 28px;
            font-weight: 800;
            color: #050505;
        }

        .page-desc {
            margin: 6px 0 0;
            color: #65676B;
            font-size: 14px;
        }

        .nav-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 22px;
            border-bottom: 1px solid #D1EBCF;
            padding-bottom: 10px;
        }

        .tab-item {
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            color: #65676B;
            background: #FFFFFF;
            border: 1px solid #D1EBCF;
            transition: all 0.15s ease;
        }

        .tab-item:hover {
            background: #EDF8F2;
            color: #050505;
        }

        .tab-item.active {
            background: #00875A;
            color: #FFFFFF;
            border-color: #00875A;
        }

        .table-card {
            background: #FFFFFF;
            border-radius: 8px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
            border: 1px solid #D1EBCF;
            overflow: hidden;
        }

        .custom-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: left;
        }

        .custom-table th {
            background: #EDF8F2;
            color: #65676B;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            font-weight: 700;
            padding: 12px 18px;
            border-bottom: 1px solid #D1EBCF;
        }

        .custom-table td {
            padding: 14px 18px;
            border-bottom: 1px solid #E2F2E5;
            color: #1C1E21;
            vertical-align: middle;
        }

        .custom-table tr:hover td {
            background: #F2F3F5;
        }

        .badge-type {
            font-size: 11.5px;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 4px;
            background: #EDF8F2;
            color: #1C1E21;
            border: 1px solid #D1EBCF;
        }

        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
            border: 1px solid #cbd5e1;
            background: white;
            color: #334155;
            cursor: pointer;
        }
        .action-btn:hover { background: #f8fafc; }
        .action-btn-danger:hover { color: #dc2626; border-color: #fca5a5; }
    </style>
</head>
<body>

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="catalog-page">
        <div class="header-box">
            <div>
                <span class="page-kicker">
                    <i class="fa-solid fa-tags"></i> Catalog Management
                </span>
                <h1 class="page-title">System Classifications &amp; Metadata</h1>
            </div>
            <% if (canManage) { %>
            <div>
                <button type="button" onclick="openAddModal()" class="action-btn" style="padding: 10px 18px; background: #f97316; color: white; border: none; font-weight: 700;">
                    <i class="fa-solid fa-plus"></i> Add Catalog Item
                </button>
            </div>
            <% } %>
        </div>

        <% if ("saved".equals(msg)) { %>
            <div style="background: #dcfce7; color: #166534; padding: 12px 18px; border-radius: 8px; border: 1px solid #bbf7d0; margin-bottom: 20px; font-weight: 600;">
                <i class="fa-solid fa-circle-check"></i> Catalog item successfully saved!
            </div>
        <% } else if ("deleted".equals(msg)) { %>
            <div style="background: #dcfce7; color: #166534; padding: 12px 18px; border-radius: 8px; border: 1px solid #bbf7d0; margin-bottom: 20px; font-weight: 600;">
                <i class="fa-solid fa-circle-check"></i> Catalog item successfully removed.
            </div>
        <% } %>

        <div class="nav-tabs">
            <a href="<%=ctx%>/catalog" class="tab-item <%= (filterType == null || filterType.isEmpty()) ? "active" : "" %>">All Categories</a>
            <a href="<%=ctx%>/catalog?type=BIN_STATUS" class="tab-item <%= "BIN_STATUS".equals(filterType) ? "active" : "" %>">Bin Statuses</a>
            <a href="<%=ctx%>/catalog?type=BIN_TYPE" class="tab-item <%= "BIN_TYPE".equals(filterType) ? "active" : "" %>">Bin / Waste Types</a>
            <a href="<%=ctx%>/catalog?type=DEVICE_TYPE" class="tab-item <%= "DEVICE_TYPE".equals(filterType) ? "active" : "" %>">IoT Device Types</a>
        </div>

        <div class="table-card">
            <table class="custom-table">
                <thead>
                    <tr>
                        <th style="width: 140px;">Category</th>
                        <th style="width: 130px;">Item Code</th>
                        <th style="width: 200px;">Item Name</th>
                        <th>Description</th>
                        <th style="width: 80px; text-align: center;">Order</th>
                        <th style="width: 90px; text-align: center;">Active</th>
                        <% if (canManage) { %>
                        <th style="width: 110px; text-align: center;">Action</th>
                        <% } %>
                    </tr>
                </thead>
                <tbody>
                    <% if (list != null && !list.isEmpty()) {
                        for (CatalogItem it : list) {
                    %>
                    <tr>
                        <td><span class="badge-type"><%= it.getCatalogType() %></span></td>
                        <td><code><%= it.getItemCode() %></code></td>
                        <td><strong><%= it.getItemName() %></strong></td>
                        <td><small style="color: #64748b;"><%= it.getDescription() != null ? it.getDescription() : "" %></small></td>
                        <td style="text-align: center;"><%= it.getDisplayOrder() %></td>
                        <td style="text-align: center;">
                            <% if (it.isActive()) { %>
                                <i class="fa-solid fa-circle-check" style="color: #10b981;"></i>
                            <% } else { %>
                                <i class="fa-solid fa-circle-xmark" style="color: #cbd5e1;"></i>
                            <% } %>
                        </td>
                        <% if (canManage) { %>
                        <td style="text-align: center;">
                            <button type="button" class="action-btn" onclick="openEditModal(<%= it.getCatalogId() %>, '<%= it.getCatalogType() %>', '<%= it.getItemCode() %>', '<%= it.getItemName().replace("'", "\\'") %>', '<%= it.getDescription() != null ? it.getDescription().replace("'", "\\'") : "" %>', <%= it.getDisplayOrder() %>, <%= it.isActive() %>)">
                                <i class="fa-solid fa-pen"></i>
                            </button>
                            <form method="POST" action="<%=ctx%>/catalog/delete" style="display: inline;" onsubmit="return confirm('Delete this catalog item?');">
                                <input type="hidden" name="id" value="<%= it.getCatalogId() %>">
                                <button type="submit" class="action-btn action-btn-danger">
                                    <i class="fa-solid fa-trash"></i>
                                </button>
                            </form>
                        </td>
                        <% } %>
                    </tr>
                    <% } } else { %>
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 35px; color: #64748b;">
                            No catalog items found in this section.
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>

    <!-- ADD / EDIT MODAL -->
    <div id="catalogModal" style="display: none; position: fixed; inset: 0; background: rgba(15,23,42,0.6); z-index: 9999; align-items: center; justify-content: center;">
        <div style="background: white; border-radius: 14px; max-width: 520px; width: 90%; padding: 26px; box-shadow: 0 20px 25px -5px rgba(0,0,0,0.2);">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 id="modalTitle" style="margin: 0; font-size: 18px; color: #0f172a;">Add Catalog Classification</h3>
                <button type="button" onclick="document.getElementById('catalogModal').style.display='none'" style="border: none; background: none; font-size: 22px; cursor: pointer; color: #64748b;">&times;</button>
            </div>
            <form method="POST" action="<%=ctx%>/catalog/save">
                <input type="hidden" name="catalogId" id="modalId" value="0">
                <div style="margin-bottom: 14px;">
                    <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Category Type *</label>
                    <select name="catalogType" id="modalType" style="width: 100%; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px; font-family: inherit;">
                        <option value="BIN_STATUS">BIN_STATUS (Waste Bin Status)</option>
                        <option value="BIN_TYPE">BIN_TYPE (Waste Classification)</option>
                        <option value="DEVICE_TYPE">DEVICE_TYPE (IoT Sensor Hardware)</option>
                    </select>
                </div>
                <div style="margin-bottom: 14px;">
                    <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Item Code *</label>
                    <input type="text" name="itemCode" id="modalCode" required style="width: 100%; box-sizing: border-box; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px;" placeholder="e.g. ULTRASONIC">
                </div>
                <div style="margin-bottom: 14px;">
                    <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Display Name *</label>
                    <input type="text" name="itemName" id="modalName" required style="width: 100%; box-sizing: border-box; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px;" placeholder="e.g. Ultrasonic Fill Sensor">
                </div>
                <div style="margin-bottom: 14px;">
                    <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Description</label>
                    <input type="text" name="description" id="modalDesc" style="width: 100%; box-sizing: border-box; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px;" placeholder="e.g. Ultrasonic distance sensor">
                </div>
                <div style="display: flex; gap: 15px; margin-bottom: 18px;">
                    <div style="flex: 1;">
                        <label style="display: block; font-size: 12px; font-weight: 700; color: #334155; margin-bottom: 4px;">Sort Order</label>
                        <input type="number" name="displayOrder" id="modalOrder" value="1" min="1" style="width: 100%; box-sizing: border-box; padding: 9px 12px; border: 1px solid #cbd5e1; border-radius: 8px;">
                    </div>
                    <div style="display: flex; align-items: center; padding-top: 18px;">
                        <label style="display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; cursor: pointer;">
                            <input type="checkbox" name="isActive" id="modalActive" value="true" checked> Active in System
                        </label>
                    </div>
                </div>
                <div style="display: flex; justify-content: flex-end; gap: 10px;">
                    <button type="button" onclick="document.getElementById('catalogModal').style.display='none'" class="action-btn" style="padding: 9px 16px;">Cancel</button>
                    <button type="submit" class="action-btn" style="padding: 9px 18px; background: #f97316; color: white; border: none; font-weight: 700;">Save Item</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openAddModal() {
            document.getElementById('modalTitle').innerText = 'Add Catalog Classification';
            document.getElementById('modalId').value = '0';
            document.getElementById('modalCode').value = '';
            document.getElementById('modalName').value = '';
            document.getElementById('modalDesc').value = '';
            document.getElementById('modalOrder').value = '1';
            document.getElementById('modalActive').checked = true;
            document.getElementById('catalogModal').style.display = 'flex';
        }

        function openEditModal(id, type, code, name, desc, order, active) {
            document.getElementById('modalTitle').innerText = 'Edit Catalog Classification';
            document.getElementById('modalId').value = id;
            document.getElementById('modalType').value = type;
            document.getElementById('modalCode').value = code;
            document.getElementById('modalName').value = name;
            document.getElementById('modalDesc').value = desc;
            document.getElementById('modalOrder').value = order;
            document.getElementById('modalActive').checked = active;
            document.getElementById('catalogModal').style.display = 'flex';
        }
    </script>
</body>
</html>
