<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="model.Notification"%>
<%@page import="util.Web"%>

<%
    String ctx = request.getContextPath();

    List<Notification> list
            = (List<Notification>) request.getAttribute("LIST_NOTIFICATION");
%>

<!DOCTYPE html>
<html lang="en">

    <head>

        <meta charset="UTF-8">

        <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0">

        <title>Notifications - SmartWaste</title>

        <link
            rel="stylesheet"
            href="<%=ctx%>/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

        <style>

            .notification-page {
                margin-left: 0;
                width: 100%;
                min-height: 100vh;
                padding: 34px 38px;
                box-sizing: border-box;
            }

            .notification-header {
                width: 100%;
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                gap: 20px;
                margin-bottom: 24px;
            }

            .page-kicker {
                display: block;
                margin-bottom: 7px;
                color: var(--green);
                font-size: 11px;
                font-weight: 800;
                letter-spacing: 1.4px;
                text-transform: uppercase;
            }

            .page-title {
                margin: 0;
                color: var(--navy);
                font-size: 30px;
                font-weight: 800;
                letter-spacing: -0.7px;
            }

            .page-description {
                margin: 8px 0 0;
                color: var(--muted);
                font-size: 14px;
            }

            .header-actions {
                display: flex;
                gap: 9px;
                flex-wrap: wrap;
            }

            .notification-btn {
                min-height: 42px;
                padding: 0 17px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 7px;
                border: 0;
                border-radius: 11px;
                cursor: pointer;
                font-family: inherit;
                font-size: 13px;
                font-weight: 700;
                text-decoration: none;
                transition: 0.2s ease;
                box-sizing: border-box;
            }

            .notification-btn-primary {
                color: var(--white);
                background: var(--green);
                box-shadow: 0 8px 18px rgba(32, 164, 90, 0.18);
            }

            .notification-btn-primary:hover {
                background: var(--green-dark);
            }

            .notification-btn-light {
                color: var(--text);
                background: var(--white);
                border: 1px solid var(--border);
            }

            .notification-btn-light:hover {
                border-color: var(--green);
                color: var(--green-dark);
            }

            .notification-panel {
                width: 100%;
                overflow: hidden;
                border: 1px solid var(--border);
                border-radius: var(--radius);
                background: var(--white);
                box-shadow: var(--shadow);
                box-sizing: border-box;
            }

            .notification-panel-header {
                width: 100%;
                padding: 19px 22px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px solid var(--border);
                box-sizing: border-box;
            }

            .panel-title {
                margin: 0;
                color: var(--navy);
                font-size: 16px;
                font-weight: 800;
            }

            .record-count {
                padding: 6px 10px;
                border-radius: 999px;
                color: var(--green-dark);
                background: var(--green-pale);
                font-size: 12px;
                font-weight: 700;
            }

            .notification-table-wrapper {
                width: 100%;
                overflow-x: auto;
            }

            .notification-table {
                width: 100%;
                min-width: 850px;
                border-collapse: collapse;
            }

            .notification-table th {
                padding: 14px 18px;
                text-align: left;
                color: var(--muted);
                background: var(--green-pale);
                border-bottom: 1px solid var(--border);
                font-size: 11px;
                font-weight: 800;
                letter-spacing: 0.5px;
                text-transform: uppercase;
                white-space: nowrap;
            }

            .notification-table td {
                padding: 15px 18px;
                border-bottom: 1px solid var(--border);
                color: var(--text);
                font-size: 13px;
                vertical-align: middle;
            }

            .notification-table tbody tr:hover {
                background: var(--green-pale);
            }

            .notification-table tbody tr:last-child td {
                border-bottom: 0;
            }

            .notification-table tr.unread {
                background: #fffaf0;
            }

            .notification-table tr.unread:hover {
                background: #fff6df;
            }

            .type {
                display: inline-flex;
                align-items: center;
                padding: 6px 10px;
                border-radius: 999px;
                background: #e9ecef;
                font-size: 11px;
                font-weight: 800;
                white-space: nowrap;
            }

            .type-ALERT {
                color: #a83232;
                background: #f8d7da;
            }

            .type-MAINTENANCE {
                color: #8a6500;
                background: #fff3cd;
            }

            .type-COLLECTION {
                color: #18794e;
                background: #d1e7dd;
            }

            .notification-message {
                max-width: 520px;
                line-height: 1.5;
            }

            .notification-time {
                color: var(--muted);
                white-space: nowrap;
            }

            .notification-status {
                display: inline-flex;
                align-items: center;
                padding: 6px 10px;
                border-radius: 999px;
                font-size: 11px;
                font-weight: 800;
                white-space: nowrap;
            }

            .status-read {
                color: var(--muted);
                background: #f0f2f2;
            }

            .status-unread {
                color: #a66a00;
                background: #fff3cd;
            }

            .action {
                white-space: nowrap;
            }

            .action-form {
                display: inline;
                margin: 0;
            }

            .action-link {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-height: 34px;
                padding: 0 11px;
                margin-right: 5px;
                gap: 5px;
                border-radius: 9px;
                border: 1px solid var(--border);
                background: var(--white);
                color: var(--text);
                font-size: 11px;
                font-weight: 700;
                text-decoration: none;
                cursor: pointer;
                font-family: inherit;
                box-sizing: border-box;
            }

            .action-link:hover {
                border-color: var(--green);
                color: var(--green-dark);
            }

            .action-open {
                color: var(--green-dark);
                border-color: var(--green);
            }

            .action-read {
                color: #18794e;
                border-color: #b8dfca;
                background: #f5fff8;
            }

            .empty-state {
                padding: 55px 20px !important;
                text-align: center;
                color: var(--muted) !important;
            }

            .empty-icon {
                width: 52px;
                height: 52px;
                margin: 0 auto 12px;
                display: grid;
                place-items: center;
                border-radius: 15px;
                color: var(--green);
                background: var(--green-pale);
                font-size: 22px;
            }

            .empty-title {
                display: block;
                margin-bottom: 4px;
                color: var(--navy);
                font-size: 14px;
                font-weight: 800;
            }

            @media (max-width: 900px) {

                .notification-page {
                    margin-left: 0;
                    width: 100%;
                    padding: 28px 24px;
                }

                .notification-header {
                    flex-direction: column;
                }

                .header-actions {
                    width: 100%;
                }

            }

            @media (max-width: 800px) {

                .notification-page {
                    margin-left: 0;
                    width: 100%;
                    padding: 25px 18px;
                }

            }

            @media (max-width: 600px) {

                .notification-page {
                    padding: 20px 14px;
                }

                .page-title {
                    font-size: 25px;
                }

                .notification-panel-header {
                    padding: 16px;
                }

                .notification-table th,
                .notification-table td {
                    padding-left: 13px;
                    padding-right: 13px;
                }

            }

        </style>

    </head>


    <body>

        <div class="app-shell">

            <!-- SHARED SIDEBAR -->

            <jsp:include page="sidebar.jsp" />


            <!-- MAIN CONTENT -->

            <main class="notification-page">


                <!-- HEADER -->

                <section class="notification-header">

                    <div>

                        <span class="page-kicker">
                            SYSTEM
                        </span>

                        <h1 class="page-title">
                            Notifications
                        </h1>

                    </div>


                    <div class="header-actions">


                        <form
                            method="post"
                            action="<%=ctx%>/notification/readall">

                            <button
                                class="notification-btn notification-btn-primary"
                                type="submit">

                                <i class="fa-solid fa-check-double"></i>

                                Mark all as read

                            </button>

                        </form>


                        <a
                            class="notification-btn notification-btn-light"
                            href="<%=ctx%>/dashboard">

                            <i class="fa-solid fa-house"></i>

                            Dashboard

                        </a>


                    </div>

                </section>

                <% 
                    Boolean isAreaHotspot = (Boolean) request.getAttribute("isAreaHotspot");
                    Integer hotspotBinCount = (Integer) request.getAttribute("hotspotBinCount");
                    Integer overdueRequests = (Integer) request.getAttribute("overdueRequests");
                    if (isAreaHotspot == null) isAreaHotspot = false;
                    if (hotspotBinCount == null) hotspotBinCount = 0;
                    if (overdueRequests == null) overdueRequests = 0;
                %>

                <% if (isAreaHotspot || overdueRequests > 0) { %>
                <!-- ACTIVE OPERATIONAL SYSTEM ALERTS -->
                <div style="margin-bottom: 24px; display: flex; flex-direction: column; gap: 12px;">
                    <% if (isAreaHotspot) { %>
                    <div style="padding: 16px 20px; background: #FEF2F2; border: 1px solid #FCA5A5; border-left: 5px solid #DC2626; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; gap: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.06);">
                        <div style="display: flex; align-items: center; gap: 14px;">
                            <div style="width: 40px; height: 40px; border-radius: 8px; background: #FEE2E2; color: #DC2626; display: grid; place-items: center; font-size: 18px; flex-shrink: 0;">
                                <i class="fa-solid fa-fire-flame-curved"></i>
                            </div>
                            <div>
                                <strong style="font-size: 14.5px; color: #991B1B; display: block; margin-bottom: 2px;">Area Capacity Alert &mdash; Simultaneous Critical Fill Threshold</strong>
                                <p style="margin: 0; font-size: 13px; color: #7F1D1D; line-height: 1.4;"><strong><%=hotspotBinCount%> waste bins</strong> in your monitored jurisdiction have reached &ge; 80% capacity. Immediate route dispatch required.</p>
                            </div>
                        </div>
                        <a href="<%=ctx%>/collection/create?mode=route&amp;hotspot=1" style="background: #DC2626; color: #FFFFFF; padding: 9px 18px; border-radius: 6px; font-size: 13px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 7px; white-space: nowrap; transition: 0.15s ease;">
                            <i class="fa-solid fa-truck-moving"></i> Dispatch Route (<%=hotspotBinCount%> Bins)
                        </a>
                    </div>
                    <% } %>

                    <% if (overdueRequests > 0) { %>
                    <div style="padding: 16px 20px; background: #FFFBEB; border: 1px solid #FDE68A; border-left: 5px solid #D97706; border-radius: 8px; display: flex; align-items: center; justify-content: space-between; gap: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.06);">
                        <div style="display: flex; align-items: center; gap: 14px;">
                            <div style="width: 40px; height: 40px; border-radius: 8px; background: #FEF3C7; color: #D97706; display: grid; place-items: center; font-size: 17px; flex-shrink: 0;">
                                <i class="fa-solid fa-clock-rotate-left"></i>
                            </div>
                            <div>
                                <strong style="font-size: 14.5px; color: #92400E; display: block; margin-bottom: 2px;">Overdue Collection SLA Warning</strong>
                                <p style="margin: 0; font-size: 13px; color: #78350F; line-height: 1.4;">There are <strong><%=overdueRequests%> collection requests</strong> exceeding SLA dispatch window (>4h).</p>
                            </div>
                        </div>
                        <a href="<%=ctx%>/collection" style="background: #FFFFFF; color: #D97706; border: 1.5px solid #D97706; padding: 8px 16px; border-radius: 6px; font-size: 13px; font-weight: 700; text-decoration: none; display: inline-flex; align-items: center; gap: 6px; white-space: nowrap; transition: 0.15s ease;">
                            Review Tasks &rarr;
                        </a>
                    </div>
                    <% } %>
                </div>
                <% } %>

                <!-- NOTIFICATION TABLE -->

                <section class="notification-panel">


                    <div class="notification-panel-header">

                        <h2 class="panel-title">
                            All Notifications
                        </h2>


                        <span class="record-count">

                            <%=list == null ? 0 : list.size()%>
                            notifications

                        </span>

                    </div>


                    <div class="notification-table-wrapper">

                        <table class="notification-table">

                            <thead>

                                <tr>

                                    <th>
                                        Type
                                    </th>

                                    <th>
                                        Message
                                    </th>

                                    <th>
                                        Time
                                    </th>

                                    <th>
                                        Status
                                    </th>

                                    <th>
                                        Action
                                    </th>

                                </tr>

                            </thead>


                            <tbody>


                                <% if (list != null
                                        && !list.isEmpty()) { %>


                                <% for (Notification n : list) {

                                    String link = null;

                                    if (n.getRefID() != null) {

                                        String ref
                                                = java.net.URLEncoder.encode(
                                                        n.getRefID(),
                                                        "UTF-8");

                                        if (Notification.TYPE_ALERT.equals(
                                                n.getNotifType())) {

                                            link = ctx
                                                    + "/alert/view?id="
                                                    + ref;

                                        } else if (
                                                Notification.TYPE_MAINTENANCE.equals(
                                                        n.getNotifType())) {

                                            link = ctx
                                                    + "/maintenance/view?id="
                                                    + ref;

                                        } else if (
                                                Notification.TYPE_COLLECTION.equals(
                                                        n.getNotifType())) {

                                            link = ctx
                                                    + "/collection/view?id="
                                                    + ref;
                                        }
                                    }

                                    String type
                                            = Web.esc(n.getNotifType());

                                %>


                                <tr class="<%=n.isRead()
                                        ? ""
                                        : "unread"%>">


                                    <!-- TYPE -->

                                    <td>

                                        <span
                                            class="type type-<%=type%>">

                                            <%=type%>

                                        </span>

                                    </td>


                                    <!-- MESSAGE -->

                                    <td>

                                        <div class="notification-message">

                                            <%=Web.esc(n.getMessage())%>

                                        </div>

                                    </td>


                                    <!-- TIME -->

                                    <td>

                                        <span class="notification-time">

                                            <%=n.getCreatedDate()%>

                                        </span>

                                    </td>


                                    <!-- STATUS -->

                                    <td>

                                        <% if (n.isRead()) { %>

                                        <span
                                            class="notification-status status-read">

                                            <i class="fa-solid fa-check"></i>
                                            &nbsp;
                                            Read

                                        </span>

                                        <% } else { %>

                                        <span
                                            class="notification-status status-unread">

                                            <i class="fa-solid fa-envelope"></i>
                                            &nbsp;
                                            Unread

                                        </span>

                                        <% } %>

                                    </td>


                                    <!-- ACTION -->

                                    <td class="action">


                                        <% if (link != null) { %>


                                        <a
                                            class="action-link action-open"
                                            href="<%=link%>">

                                            <i class="fa-solid fa-arrow-up-right-from-square"></i>

                                            Open

                                        </a>


                                        <% } %>


                                        <% if (!n.isRead()) { %>


                                        <form
                                            class="action-form"
                                            method="post"
                                            action="<%=ctx%>/notification/read">


                                            <input
                                                type="hidden"
                                                name="id"
                                                value="<%=n.getNotificationID()%>">


                                            <button
                                                class="action-link action-read"
                                                type="submit">

                                                <i class="fa-solid fa-check"></i>

                                                Mark read

                                            </button>


                                        </form>


                                        <% } %>


                                    </td>

                                </tr>


                                <% } %>


                                <% } else { %>


                                <tr>

                                    <td
                                        colspan="5"
                                        class="empty-state">

                                        <div class="empty-icon">

                                            <i class="fa-solid fa-bell-slash"></i>

                                        </div>

                                        <span class="empty-title">
                                            No notifications
                                        </span>

                                        You're all caught up.

                                    </td>

                                </tr>


                                <% } %>


                            </tbody>

                        </table>

                    </div>

                </section>


            </main>

        </div>

    </body>

</html>