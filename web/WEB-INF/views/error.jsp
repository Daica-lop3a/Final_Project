<%@page contentType="text/html" pageEncoding="UTF-8" isErrorPage="true"%>
<%
    Integer statusCode = (Integer) request.getAttribute("javax.servlet.error.status_code");
    if (statusCode == null) {
        statusCode = response.getStatus();
    }
    if (statusCode == null || statusCode == 200) {
        statusCode = 500;
    }

    String errorTitle = "Unexpected System Error";
    String errorMsg = "An unexpected error occurred while processing your request. Our technical team has been notified.";
    String iconClass = "fa-triangle-exclamation";
    String iconBg = "#FEE2E2";
    String iconColor = "#DC2626";

    if (statusCode == 404) {
        errorTitle = "Page Not Found";
        errorMsg = "The resource or endpoint you requested does not exist or may have been relocated.";
        iconClass = "fa-magnifying-glass";
        iconBg = "#FEF3C7";
        iconColor = "#D97706";
    } else if (statusCode == 403) {
        errorTitle = "Access Forbidden";
        errorMsg = "You do not have the required permissions to access this requested resource.";
        iconClass = "fa-lock";
        iconBg = "#FEE2E2";
        iconColor = "#DC2626";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= statusCode %> - <%= errorTitle %> - SmartWaste</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body {
            margin: 0;
            background: #EDF8F2;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            display: grid;
            place-items: center;
            min-height: 100vh;
            color: #1C1E21;
        }
        .error-card {
            background: #FFFFFF;
            border: 1px solid #D1EBCF;
            border-radius: 12px;
            padding: 40px;
            max-width: 480px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0, 135, 90, 0.08);
        }
        .error-code {
            font-size: 13px;
            font-weight: 700;
            color: #00875A;
            background: #D1EBCF;
            padding: 3px 10px;
            border-radius: 999px;
            display: inline-block;
            margin-bottom: 16px;
            letter-spacing: 0.5px;
        }
        .error-icon {
            width: 68px;
            height: 68px;
            border-radius: 50%;
            background: <%= iconBg %>;
            color: <%= iconColor %>;
            font-size: 30px;
            display: grid;
            place-items: center;
            margin: 0 auto 20px;
        }
        h2 {
            margin: 0 0 10px;
            font-size: 22px;
            font-weight: 800;
            color: #050505;
        }
        p {
            margin: 0 0 28px;
            font-size: 14.5px;
            color: #65676B;
            line-height: 1.55;
        }
        .btn-group {
            display: flex;
            gap: 12px;
            justify-content: center;
            flex-wrap: wrap;
        }
        .btn-primary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 22px;
            background: #00875A;
            color: #FFFFFF;
            text-decoration: none;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            transition: background 0.15s ease;
        }
        .btn-primary:hover {
            background: #006644;
        }
        .btn-secondary {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #F0F2F5;
            color: #1C1E21;
            text-decoration: none;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            transition: background 0.15s ease;
        }
        .btn-secondary:hover {
            background: #E4E6EB;
        }
    </style>
</head>
<body>
    <div class="error-card">
        <span class="error-code">ERROR <%= statusCode %></span>
        <div class="error-icon">
            <i class="fa-solid <%= iconClass %>"></i>
        </div>
        <h2><%= errorTitle %></h2>
        <p><%= errorMsg %></p>
        <div class="btn-group">
            <a href="<%=request.getContextPath()%>/dashboard" class="btn-primary">
                <i class="fa-solid fa-house"></i> Go to Dashboard
            </a>
            <a href="javascript:history.back()" class="btn-secondary">
                <i class="fa-solid fa-arrow-left"></i> Go Back
            </a>
        </div>
    </div>
</body>
</html>
