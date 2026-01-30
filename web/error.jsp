<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String errorMsg = (String) request.getAttribute("error");
    String debugInfo = (String) request.getAttribute("debug_info");
    if (errorMsg == null) errorMsg = "An unknown error occurred";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Error</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .error-box { 
            border: 2px solid #dc3545; 
            padding: 20px; 
            border-radius: 5px; 
            background-color: #f8d7da;
            color: #721c24;
            margin: 20px 0;
        }
        .debug-info {
            background-color: #e9ecef;
            padding: 10px;
            border-radius: 3px;
            margin-top: 10px;
            font-family: monospace;
        }
    </style>
</head>
<body>
    <h1>Error</h1>
    <div class="error-box">
        <h3><%= errorMsg %></h3>
        <% if (debugInfo != null) { %>
            <div class="debug-info">
                Debug: <%= debugInfo %>
            </div>
        <% } %>
    </div>
    <a href="AllRequestsServlet" style="display: inline-block; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 4px;">Back to Requests</a>
</body>
</html>