<%@page import="com.recyclehub.model.Collector"%>
<%@page import="com.recyclehub.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    Collector collector = (Collector) request.getAttribute("collector");
    if (collector == null) {
        response.sendRedirect("AdminCollectorServlet");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Collector - RecycleHub</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="AdminDashboardServlet" class="logo"><span>♻️</span> RecycleHub Admin</a>
            <div class="user-menu"><a href="LogoutServlet" class="btn btn-danger">Logout</a></div>
        </div>
    </header>
    
    <main class="container">
        <div class="page-container active" style="display: block;">
            <h1 class="page-title">Edit Collector: <%= collector.getName() %></h1>
            
            <div class="card">
                <form action="AdminCollectorServlet" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= collector.getCollectorId() %>">
                    
                    <div class="form-group">
                        <label class="form-label">Name *</label>
                        <input type="text" name="name" class="form-control" 
                               value="<%= collector.getName() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Phone Number *</label>
                        <input type="tel" name="phone" class="form-control" 
                               value="<%= collector.getPhone() %>" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Plate Number (Vehicle)</label>
                        <input type="text" name="plateNumber" class="form-control" 
                               value="<%= collector.getPlateNumber() != null ? collector.getPlateNumber() : "" %>">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control">
                            <option value="Available" <%= "Available".equals(collector.getStatus()) ? "selected" : "" %>>Available</option>
                            <option value="Busy" <%= "Busy".equals(collector.getStatus()) ? "selected" : "" %>>Busy</option>
                            <option value="On Leave" <%= "On Leave".equals(collector.getStatus()) ? "selected" : "" %>>On Leave</option>
                        </select>
                    </div>
                    
                    <div style="margin-top: 30px; display: flex; gap: 15px;">
                        <button type="submit" class="btn btn-primary">Update Collector</button>
                        <a href="AdminCollectorServlet" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </main>
    
    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="logo" style="font-size: 20px;">
                    <span>♻️</span>
                    <span>RecycleHub</span>
                </div>
                <div class="copyright">
                    &copy; 2023 RecycleHub. All rights reserved.
                </div>
            </div>
        </div>
    </footer>
</body>
</html>