<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Area"%>
<%@page import="model.AppUser"%>

<%!
    // Escape HTML to prevent HTML injection and XSS.
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    List<Area> list =
            (List<Area>) request.getAttribute("AREAS");

    String error =
            (String) request.getAttribute("ERROR");

    String search =
            (String) request.getAttribute("SEARCH");

    String sort =
            (String) request.getAttribute("SORT");

    String order =
            (String) request.getAttribute("ORDER");

    String areaScope =
            (String) request.getAttribute("AREA_SCOPE");

    if (search == null) {
        search = "";
    }

    if (sort == null || sort.isEmpty()) {
        sort = "areaID";
    }

    if (order == null || order.isEmpty()) {
        order = "ASC";
    }

    if (areaScope == null || areaScope.isEmpty()) {
        areaScope = "all";
    }

    AppUser currentUser =
            (AppUser) session.getAttribute("user");

    String role = currentUser != null
            && currentUser.getRoleId() != null
            ? currentUser.getRoleId().trim().toUpperCase(Locale.ROOT)
            : "";

    // Super Admin, Admin & Operations Manager can create, edit and delete areas.
    boolean isAdmin = "ADM".equals(role) || "SAD".equals(role) || "MGR".equals(role);

    boolean isRegularUser = "USR".equals(role);

    int currentPage = 1;
    int totalPages = 1;
    int totalRecords = 0;
    int pageSize = 10;

    Object cp = request.getAttribute("CURRENT_PAGE");
    Object tp = request.getAttribute("TOTAL_PAGES");
    Object tr = request.getAttribute("TOTAL_RECORDS");

    if (cp instanceof Number) {
        currentPage = ((Number) cp).intValue();
    }

    if (tp instanceof Number) {
        totalPages = ((Number) tp).intValue();
    }

    if (tr instanceof Number) {
        totalRecords = ((Number) tr).intValue();
    }

    if (currentPage < 1) {
        currentPage = 1;
    }

    if (totalPages < 1) {
        totalPages = 1;
    }

    if (currentPage > totalPages) {
        currentPage = totalPages;
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Area Management | SmartWaste</title>

    <link rel="stylesheet" href="<%=ctx%>/css/style.css">
    <link rel="stylesheet" href="<%=ctx%>/css/wastebin.css">
</head>

<body>
<div class="app-shell">

    <jsp:include page="/WEB-INF/views/sidebar.jsp" />

    <main class="main-content">

        <!-- Header -->
        <header class="topbar">
            <div>
                <div class="eyebrow">SMARTWASTE MANAGEMENT</div>
                <h1>Area Management</h1>
            </div>

            <div class="topbar-actions">
                <div class="profile">
                    <div class="avatar">
                        <%= escapeHtml(
                                currentUser != null
                                && currentUser.getFullName() != null
                                && !currentUser.getFullName().isEmpty()
                                ? currentUser.getFullName().substring(0, 1)
                                    .toUpperCase(Locale.ROOT)
                                : "U")
                        %>
                    </div>

                    <div class="profile-info">
                        <strong>
                            <%= escapeHtml(
                                    currentUser != null
                                    ? currentUser.getFullName()
                                    : "")
                            %>
                        </strong>
                        <span><%=escapeHtml(role)%></span>
                    </div>
                </div>
            </div>
        </header>

        <!-- Page introduction -->
        <section class="page-intro">
            <div>
                <span class="section-kicker">AREA MANAGEMENT</span>
                <h2>Manage waste collection areas</h2>
                <p>
                    View, search and manage areas in the
                    waste management system.
                </p>
            </div>

            <div class="page-actions">

                <% if (isAdmin) { %>
                <a class="btn btn-primary"
                   href="<%=ctx%>/area/create">
                    <span>+</span>
                    Add Area
                </a>
                <% } %>

                <a class="btn btn-light"
                   href="<%=ctx%>/dashboard">
                    Dashboard
                </a>
            </div>
        </section>

        <!-- Error message -->
        <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert-error">
            <span class="alert-error-icon">!</span>
            <span><%=escapeHtml(error)%></span>
        </div>
        <% } %>

        <!-- Filters -->
        <section class="panel">
            <div class="panel-header">
                <div>
                    <span class="panel-kicker">FILTER &amp; SORT</span>
                    <h3>Area Filters</h3>
                </div>
            </div>

            <form method="GET" action="<%=ctx%>/area">
                <div style="
                    display:flex;
                    align-items:flex-end;
                    gap:12px;
                    flex-wrap:wrap;
                    margin-top:18px;
                ">

                    <% if (isRegularUser) { %>
                    <div style="display:flex; flex-direction:column; gap:6px;">
                        <label for="scope"
                               style="font-size:11px; font-weight:700; color:var(--muted);">
                            Area Scope
                        </label>

                        <select id="scope" name="scope"
                                style="min-height:42px; min-width:160px; padding:0 13px; border:1px solid var(--border); border-radius:11px; background:var(--white); color:var(--text); font-size:12px;">

                            <option value="all"
                                <%= "all".equals(areaScope) ? "selected" : "" %>>
                                All Areas
                            </option>

                            <option value="my"
                                <%= "my".equals(areaScope) ? "selected" : "" %>>
                                My Area
                            </option>
                        </select>
                    </div>
                    <% } %>

                    <div style="display:flex; flex-direction:column; gap:6px;">
                        <label for="search"
                               style="font-size:11px; font-weight:700; color:var(--muted);">
                            Search
                        </label>

                        <input type="text"
                               id="search"
                               name="search"
                               value="<%=escapeHtml(search)%>"
                               placeholder="Area ID / Area Name"
                               style="min-height:42px; min-width:230px; padding:0 13px; border:1px solid var(--border); border-radius:11px; outline:none; background:var(--white); color:var(--text); font-size:12px;">
                    </div>

                    <div style="display:flex; flex-direction:column; gap:6px;">
                        <label for="sort"
                               style="font-size:11px; font-weight:700; color:var(--muted);">
                            Sort by
                        </label>

                        <select id="sort" name="sort"
                                style="min-height:42px; min-width:160px; padding:0 13px; border:1px solid var(--border); border-radius:11px; background:var(--white); color:var(--text); font-size:12px;">

                            <option value="areaID"
                                <%= "areaID".equals(sort) ? "selected" : "" %>>
                                Area ID
                            </option>

                            <option value="areaName"
                                <%= "areaName".equals(sort) ? "selected" : "" %>>
                                Area Name
                            </option>
                        </select>
                    </div>

                    <div style="display:flex; flex-direction:column; gap:6px;">
                        <label for="order"
                               style="font-size:11px; font-weight:700; color:var(--muted);">
                            Order
                        </label>

                        <select id="order" name="order"
                                style="min-height:42px; min-width:130px; padding:0 13px; border:1px solid var(--border); border-radius:11px; background:var(--white); color:var(--text); font-size:12px;">

                            <option value="ASC"
                                <%= "ASC".equals(order) ? "selected" : "" %>>
                                ASC
                            </option>

                            <option value="DESC"
                                <%= "DESC".equals(order) ? "selected" : "" %>>
                                DESC
                            </option>
                        </select>
                    </div>

                    <div style="display:flex; gap:8px;">
                        <button type="submit" class="btn btn-primary">
                            Apply Filter
                        </button>

                        <a href="<%=ctx%>/area" class="btn btn-light">
                            Reset
                        </a>
                    </div>
                </div>
            </form>
        </section>

        <!-- Area list -->
        <section class="panel" style="margin-top:20px;">

            <div class="panel-header">
                <div>
                    <span class="panel-kicker">AREA INVENTORY</span>
                    <h3>Area List</h3>
                </div>

                <span class="record-count">
                    <%=totalRecords%> records
                </span>
            </div>

            <div class="table-wrapper" style="margin-top:18px;">
                <table class="data-table">
                    <thead>
                    <tr>
                        <th>Area ID</th>
                        <th>Area Name</th>
                        <th>Description</th>
                        <th>Action</th>
                    </tr>
                    </thead>

                    <tbody>
                    <% if (list != null && !list.isEmpty()) {
                        for (Area area : list) {
                            String encodedAreaId = "";
                            if (area.getAreaId() != null) {
                                encodedAreaId = URLEncoder.encode(
                                        area.getAreaId(), "UTF-8");
                            }
                    %>
                    <tr>
                        <td>
                            <span class="bin-id">
                                #<%=escapeHtml(area.getAreaId())%>
                            </span>
                        </td>

                        <td>
                            <span class="bin-code">
                                <%=escapeHtml(area.getAreaName())%>
                            </span>
                        </td>

                        <td>
                            <span style="color:var(--muted); font-size:13px;">
                                <%=escapeHtml(area.getDescription())%>
                            </span>
                        </td>

                        <td>
                            <div class="action-group">

                                <a href="<%=ctx%>/area/view?id=<%=encodedAreaId%>"
                                   class="action-btn action-view">
                                    View
                                </a>

                                <% if (isAdmin) { %>
                                <a href="<%=ctx%>/area/edit?id=<%=encodedAreaId%>"
                                   class="action-btn action-edit">
                                    Edit
                                </a>

                                <form action="<%=ctx%>/area/delete"
                                      method="POST"
                                      onsubmit="return confirm('Are you sure you want to delete this area?');">

                                    <input type="hidden"
                                           name="id"
                                           value="<%=escapeHtml(area.getAreaId())%>">

                                    <button type="submit"
                                            class="action-btn action-delete">
                                        Delete
                                    </button>
                                </form>
                                <% } %>

                            </div>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="4">
                            <div class="empty-state">
                                <div class="empty-icon">⌖</div>
                                <strong>No areas found</strong>
                                <span>
                                    There are currently no areas
                                    available in the system.
                                </span>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Shared pagination -->
            <%
                request.setAttribute(
                        "PAGINATION_BASE_URL", ctx + "/area");
                request.setAttribute(
                        "PAGINATION_CURRENT_PAGE", currentPage);
                request.setAttribute(
                        "PAGINATION_TOTAL_PAGES", totalPages);
                request.setAttribute(
                        "PAGINATION_TOTAL_RECORDS", totalRecords);
                request.setAttribute(
                        "PAGINATION_PAGE_SIZE", pageSize);
            %>

            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />

        </section>

        <footer class="footer">
            <span>SmartWaste Management System</span>
            <span>Area Management</span>
        </footer>

    </main>
</div>
</body>
</html>
