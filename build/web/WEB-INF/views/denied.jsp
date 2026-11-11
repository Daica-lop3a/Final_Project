<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Access Denied - SmartWaste</title>
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
        .denied-card {
            background: #FFFFFF;
            border: 1px solid #D1EBCF;
            border-radius: 10px;
            padding: 40px;
            max-width: 460px;
            text-align: center;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        .denied-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            background: #FEE2E2;
            color: #DC2626;
            font-size: 28px;
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
            margin: 0 0 24px;
            font-size: 14px;
            color: #65676B;
            line-height: 1.5;
        }
        .btn-back {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #00875A;
            color: #FFFFFF;
            text-decoration: none;
            border-radius: 6px;
            font-size: 13.5px;
            font-weight: 600;
            transition: background 0.15s ease;
        }
        .btn-back:hover {
            background: #006644;
        }
    </style>
</head>
<body>
    <div class="denied-card">
        <div class="denied-icon">
            <i class="fa-solid fa-lock"></i>
        </div>
        <h2>Access Restricted</h2>
        <p>
            You do not have the necessary security authorization or permissions to access this requested view.
        </p>
        <a href="<%=request.getContextPath()%>/dashboard" class="btn-back">
            <i class="fa-solid fa-arrow-left"></i> Return to Dashboard
        </a>
    </div>
</body>
</html>
