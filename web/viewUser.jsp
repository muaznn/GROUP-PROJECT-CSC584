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
    
    String roleClass = "role-user";
    String roleText = user.getRole() != null ? user.getRole() : "user";
    
    if ("admin".equalsIgnoreCase(roleText)) {
        roleClass = "role-admin";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View User - RecycleHub</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .detail-container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-top: 20px;
        }
        
        .detail-item {
            margin-bottom: 20px;
            padding-bottom: 20px;
            border-bottom: 1px solid #e9ecef;
            display: flex;
            align-items: flex-start;
        }
        
        .detail-item:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }
        
        .detail-label {
            font-weight: 600;
            color: #495057;
            min-width: 160px;
            font-size: 14px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .detail-label i {
            color: #3498db;
            width: 20px;
        }
        
        .detail-value {
            color: #2c3e50;
            flex: 1;
            font-size: 15px;
            line-height: 1.6;
        }
        
        .user-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid #e9ecef;
        }
        
        .user-id {
            font-size: 20px;
            font-weight: 700;
            color: #2c3e50;
        }
        
        .user-name {
            font-size: 18px;
            color: #495057;
            margin-top: 5px;
        }
        
        .role-badge {
            display: inline-block;
            padding: 6px 15px;
            border-radius: 15px;
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
        }
        
        .role-admin {
            background-color: #dc3545;
            color: white;
        }
        
        .role-user {
            background-color: #28a745;
            color: white;
        }
        
        .back-action {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e9ecef;
            display: flex;
            gap: 15px;
        }
        
        
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .alert-success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        
        .points-value {
            font-weight: 600;
            color: #f39c12;
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
            <h1 class="page-title">
                User Details
            </h1>
            
            <%-- Display messages --%>
            <% if (session.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success">
                    <i class="fas fa-check-circle" style="margin-right: 10px;"></i>
                    <%= session.getAttribute("successMessage") %>
                </div>
                <% session.removeAttribute("successMessage"); %>
            <% } %>
            
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle" style="margin-right: 10px;"></i>
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>
            
            <div class="detail-container">
                <div class="user-header">
                    <div>
                        <div class="user-id">USR-<%= String.format("%04d", user.getUserId()) %></div>
                        <div class="user-name"><%= user.getName() %></div>
                    </div>
                    
                </div>
                
                <!-- All details listed top to bottom -->
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-id-card"></i>
                        User ID:
                    </span>
                    <span class="detail-value">
                        <strong>USR-<%= String.format("%04d", user.getUserId()) %></strong>
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-user"></i>
                        Full Name:
                    </span>
                    <span class="detail-value">
                        <%= user.getName() %>
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-envelope"></i>
                        Email Address:
                    </span>
                    <span class="detail-value">
                        <%= user.getEmail() %>
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-phone"></i>
                        Phone Number:
                    </span>
                    <span class="detail-value">
                        <% if (user.getPhone() != null && !user.getPhone().isEmpty()) { %>
                            <%= user.getPhone() %>
                        <% } else { %>
                            <span style="color: #6c757d; font-style: italic;">Not provided</span>
                        <% } %>
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-home"></i>
                        Address:
                    </span>
                    <span class="detail-value">
                        <% if (user.getAddress() != null && !user.getAddress().isEmpty()) { %>
                            <%= user.getAddress() %>
                        <% } else { %>
                            <span style="color: #6c757d; font-style: italic;">Not provided</span>
                        <% } %>
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-user-tag"></i>
                        Account Role:
                    </span>
                    <span class="detail-value">
                        <span class="role-badge <%= roleClass %>">
                            <%= roleText.toUpperCase() %>
                        </span>
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-star"></i>
                        Reward Points:
                    </span>
                    <span class="detail-value points-value">
                        <%= user.getCurrentPoints() %> points
                    </span>
                </div>
                
                <div class="detail-item">
                    <span class="detail-label">
                        <i class="fas fa-lock"></i>
                        Password:
                    </span>
                    <span class="detail-value">
                        <span style="font-family: monospace;">••••••••</span>
                        <span style="font-size: 12px; color: #6c757d; margin-left: 10px;">
                            (hidden for security)
                        </span>
                    </span>
                </div>
                
                <!-- Action Buttons -->
                <div class="back-action">
                    <a href="AdminUserServlet" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i>
                        Back to List
                    </a>
                    
                    <a href="AdminUserServlet?action=edit&id=<%= user.getUserId() %>" class="btn btn-primary">
                        <i class="fas fa-edit"></i>
                        Edit User
                    </a>
                    
                    <% if (user.getUserId() != loggedInUser.getUserId()) { %>
                    <form action="AdminUserServlet" method="POST" 
                          onsubmit="return confirmDelete('<%= user.getName() %>')"
                          style="display: inline;">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= user.getUserId() %>">
                        <button type="submit" class="btn btn-danger">
                            <i class="fas fa-trash-alt"></i>
                            Delete User
                        </button>
                    </form>
                    <% } else { %>
                    <button class="btn btn-secondary" 
                            style="opacity: 0.6; cursor: not-allowed;"
                            title="Cannot delete your own account">
                        <i class="fas fa-trash-alt"></i>
                        Delete User
                    </button>
                    <% } %>
                </div>
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
                <div style="text-align: right;">
                    <p>Community Recycling Collection System</p>
                    <p>Helping communities recycle better</p>
                </div>
            </div>
            <div class="copyright">
                &copy; 2023 RecycleHub. All rights reserved.
            </div>
        </div>
    </footer>

    <script>
        function confirmDelete(userName) {
            return confirm('Are you sure you want to delete user "' + userName + '"?\n\nThis action cannot be undone.');
        }
    </script>
</body>
</html>