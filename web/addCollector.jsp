<%@page import="com.recyclehub.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Collector - RecycleHub</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="../DashboardServlet" class="logo">
                <span>♻️</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul id="nav-menu">
                    <li><a href="AdminDashboardServlet">Dashboard</a></li>
                    <li><a href="AllRequestsServlet">All Requests</a></li>
                    <li><a href="AdminCollectorServlet">Manage Collectors</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= user.getName() %></span>
                <span id="user-role" class="user-role">Admin</span>
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>
    
    <main class="container">
        <div class="page-container active" style="display: block;">
            <h1 class="page-title">Add New Collector</h1>
            
            <div class="card">
                <form action="AdminCollectorServlet" method="POST">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-group">
                        <label class="form-label">Name *</label>
                        <input type="text" name="name" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Phone Number *</label>
                        <input type="tel" name="phone" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Plate Number (Vehicle)</label>
                        <input type="text" name="plateNumber" class="form-control">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-control">
                            <option value="Available">Available</option>
                            <option value="Busy">Busy</option>
                            <option value="On Leave">On Leave</option>
                        </select>
                    </div>
                    
                    <div style="margin-top: 30px; display: flex; gap: 15px;">
                        <button type="submit" class="btn btn-primary">Save Collector</button>
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