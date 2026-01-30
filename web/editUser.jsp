<%@page import="com.recyclehub.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is admin
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    User user = (User) request.getAttribute("user");
    if (user == null) {
        response.sendRedirect("AdminUserServlet");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit User - RecycleHub</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .card {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #374151;
            font-size: 14px;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 14px;
            box-sizing: border-box;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #3498db;
        }

    </style>
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="AdminDashboardServlet" class="logo">
                <span>♻️</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul id="nav-menu">
                    <li><a href="AdminDashboardServlet">Dashboard</a></li>
                    <li><a href="AllRequestsServlet">All Requests</a></li>
                    <li><a href="AdminCollectorServlet">Manage Collectors</a></li>
                    <li><a href="AdminUserServlet" style="font-weight: bold; background-color: rgba(255, 255, 255, 0.1);">Manage Users</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= loggedInUser.getName() %></span>
                <span class="user-role">Admin</span>
                <a href="LogoutServlet" class="btn btn-danger">Logout</a>
            </div>
        </div>
    </header>
    
    <main class="container">
        <div class="page-container active" style="display: block;">
            <h1 class="page-title">Edit User: <%= user.getName() %></h1>
            
            <%-- Display messages --%>
            <% if (session.getAttribute("errorMessage") != null) { %>
                <div class="alert" style="background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                    <%= session.getAttribute("errorMessage") %>
                </div>
                <% session.removeAttribute("errorMessage"); %>
            <% } %>
            
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert" style="background-color: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>
            
            <div class="card">
                <form action="AdminUserServlet" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= user.getUserId() %>">
                    
                    <div class="form-group">
                        <label class="form-label">Name *</label>
                        <input type="text" name="name" class="form-control" 
                               value="<%= user.getName() != null ? user.getName() : "" %>" 
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Email Address *</label>
                        <input type="email" name="email" class="form-control" 
                               value="<%= user.getEmail() != null ? user.getEmail() : "" %>" 
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Phone Number</label>
                        <input type="tel" name="phone" class="form-control" 
                               value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Address</label>
                        <textarea name="address" class="form-control" rows="3"><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Account Role</label>
                        <select name="role" class="form-control">
                            <option value="user" <%= "user".equals(user.getRole()) ? "selected" : "" %>>Regular User</option>
                            <option value="admin" <%= "admin".equals(user.getRole()) ? "selected" : "" %>>Administrator</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Current Points</label>
                        <input type="number" name="currentPoints" class="form-control" 
                               value="<%= user.getCurrentPoints() %>" min="0">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label">Password</label>
                        <input type="password" name="password" class="form-control" 
                               placeholder="Leave blank to keep current password">
                        <small style="color: #6c757d; font-size: 12px; display: block; margin-top: 5px;">
                            Only fill if you want to change the password
                        </small>
                    </div>
                    
                    <div style="margin-top: 30px; display: flex; gap: 15px;">
                        <button type="submit" class="btn btn-primary">Update User</button>
                        <a href="AdminUserServlet" class="btn btn-secondary">Cancel</a>
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