<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Map"%>

<%
    String baseUrl = (String) request.getAttribute(
            "PAGINATION_BASE_URL"
    );

    Object currentValue = request.getAttribute(
            "PAGINATION_CURRENT_PAGE"
    );

    Object pagesValue = request.getAttribute(
            "PAGINATION_TOTAL_PAGES"
    );

    Object recordsValue = request.getAttribute(
            "PAGINATION_TOTAL_RECORDS"
    );

    Object sizeValue = request.getAttribute(
            "PAGINATION_PAGE_SIZE"
    );

    int currentPage = currentValue instanceof Number
            ? ((Number) currentValue).intValue() : 1;

    int totalPages = pagesValue instanceof Number
            ? ((Number) pagesValue).intValue() : 1;

    int totalRecords = recordsValue instanceof Number
            ? ((Number) recordsValue).intValue() : 0;

    int pageSize = sizeValue instanceof Number
            ? ((Number) sizeValue).intValue() : 10;

    if (baseUrl == null || baseUrl.isEmpty()) {
        baseUrl = request.getRequestURI();
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

    if (pageSize < 1) {
        pageSize = 10;
    }

    StringBuilder query = new StringBuilder();

    Map<String, String[]> parameters = request.getParameterMap();

    for (Map.Entry<String, String[]> entry : parameters.entrySet()) {

        String name = entry.getKey();

        if ("page".equals(name)) {
            continue;
        }

        String[] values = entry.getValue();

        if (values == null) {
            continue;
        }

        for (String value : values) {

            if (query.length() > 0) {
                query.append("&amp;");
            }

            query.append(
                    URLEncoder.encode(name, "UTF-8")
            );

            query.append("=");

            query.append(
                    URLEncoder.encode(
                            value == null ? "" : value,
                            "UTF-8"
                    )
            );
        }
    }

    String querySuffix = query.length() > 0
            ? "&amp;" + query.toString()
            : "";

    int firstRecord = totalRecords == 0
            ? 0
            : (currentPage - 1) * pageSize + 1;

    int lastRecord = Math.min(
            currentPage * pageSize,
            totalRecords
    );
%>

<style>
    .pagination-shared {
        display: flex;
        justify-content: space-between;
        align-items: center;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 18px;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }

    .pagination-shared-info {
        color: #65676B;
        font-size: 13px;
        font-weight: 500;
    }

    .pagination-shared-controls {
        display: flex;
        align-items: center;
        flex-wrap: wrap;
        gap: 6px;
    }

    .pagination-shared-link,
    .pagination-shared-current {
        min-width: 36px;
        min-height: 36px;
        padding: 0 11px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        border: 1px solid #D1EBCF;
        border-radius: 6px;
        box-sizing: border-box;
        font-family: inherit;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
        transition: background .15s ease, color .15s ease, border-color .15s ease;
    }

    .pagination-shared-link {
        background: #FFFFFF;
        color: #1C1E21;
    }

    .pagination-shared-link:hover {
        color: #050505;
        background: #EDF8F2;
        border-color: #D1EBCF;
    }

    .pagination-shared-current {
        color: #FFFFFF;
        background: #00875A;
        border-color: #00875A;
        font-weight: 700;
        box-shadow: none;
        cursor: default;
    }

    .pagination-shared-ellipsis {
        min-width: 24px;
        text-align: center;
        color: #65676B;
        font-size: 14px;
        font-weight: 700;
    }

    @media (max-width: 600px) {
        .pagination-shared {
            align-items: flex-start;
        }

        .pagination-shared-controls {
            gap: 5px;
        }

        .pagination-shared-link,
        .pagination-shared-current {
            min-width: 34px;
            min-height: 34px;
            padding: 0 8px;
            font-size: 12px;
        }
    }
</style>

<div class="pagination-shared">

    <div class="pagination-shared-info">
        Showing <%=firstRecord%> - <%=lastRecord%>
        of <%=totalRecords%> records
    </div>

    <% if (totalRecords > 0) { %>

    <div class="pagination-shared-controls">

        <% if (currentPage > 1) {%>

        <a class="pagination-shared-link"
           href="<%=baseUrl%>?page=<%=currentPage - 1%><%=querySuffix%>">
            Previous
        </a>

        <% } %>

        <%
            boolean inGap = false;

            for (int i = 1; i <= totalPages; i++) {

                boolean showPage
                        = totalPages <= 7
                        || i == 1
                        || i == totalPages
                        || (i >= currentPage - 1
                        && i <= currentPage + 1)
                        || (currentPage <= 2 && i <= 3)
                        || (currentPage >= totalPages - 1
                        && i >= totalPages - 2);

                if (showPage) {

                    inGap = false;

                    if (i == currentPage) {
        %>

        <span class="pagination-shared-current"
              aria-current="page">
            <%=i%>
        </span>

        <%          } else {%>

        <a class="pagination-shared-link"
           href="<%=baseUrl%>?page=<%=i%><%=querySuffix%>">
            <%=i%>
        </a>

        <%
            }

        } else if (!inGap) {

            inGap = true;
        %>

        <span class="pagination-shared-ellipsis">...</span>

        <%
                }
            }
        %>

        <% if (currentPage < totalPages) {%>

        <a class="pagination-shared-link"
           href="<%=baseUrl%>?page=<%=currentPage + 1%><%=querySuffix%>">
            Next
        </a>

        <% } %>

    </div>

    <% }%>

</div>