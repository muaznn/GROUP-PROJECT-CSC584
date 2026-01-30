<%@page import="com.recyclehub.model.User"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Check if user is admin
    User loggedInUser = (User) session.getAttribute("user");
    if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Get users list from request attribute
    List<User> allUsers = (List<User>) request.getAttribute("users");
    if (allUsers == null) {
        allUsers = new ArrayList<User>();
    }
    
    // Pagination parameters
    int pageSize = 10; // 10 users per page
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    
    if (pageParam != null && !pageParam.trim().isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }
    
    // Calculate pagination
    int totalUsers = allUsers.size();
    int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
    
    // Ensure current page is within bounds
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    
    // Get sublist for current page
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalUsers);
    List<User> pageUsers = null;
    
    if (startIndex < totalUsers) {
        pageUsers = allUsers.subList(startIndex, endIndex);
    } else {
        pageUsers = new ArrayList<User>();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Manage Users</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Reuse styles from collectors page with modifications */
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .stat-card h3 {
            margin: 0 0 10px 0;
            color: #2c3e50;
            font-size: 14px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .stat-card .number {
            font-size: 32px;
            font-weight: bold;
            color: #3498db;
        }
        .table-container {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 30px;
        }
        .table-header {
            padding: 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        /* Status badges for roles */
        .role-badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-weight: bold;
            font-size: 0.85em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .role-admin {
            background-color: #dc3545;
            color: white;
        }
        .role-user {
            background-color: #28a745;
            color: white;
        }
        
        /* Points badge */
        .points-badge {
            background-color: #ffc107;
            color: black;
            padding: 3px 8px;
            border-radius: 12px;
            font-weight: bold;
            font-size: 0.8em;
        }
        
        /* Action buttons */
        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: nowrap;
        }
        
        .action-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            border: none;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
            font-size: 14px;
        }
        
        .btn-view { 
            background: #e2e8f0; 
            color: #475569; 
        }
        .btn-view:hover { 
            background: #cbd5e1; 
            color: #1e293b; 
        }
        
        .btn-edit { 
            background: #dbeafe; 
            color: #2563eb; 
        }
        .btn-edit:hover { 
            background: #bfdbfe; 
            color: #1d4ed8; 
        }
        
        
        
        .btn-secondary { 
            background: #e5e7eb; 
            color: #374151; 
        }
        .btn-secondary:hover { 
            background: #d1d5db; 
            color: #111827; 
        }
        
        /* Pagination styling */
        .pagination-container {
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
            border-top: 1px solid #eee;
            gap: 10px;
        }
        
        .pagination {
            display: flex;
            gap: 5px;
            list-style: none;
            margin: 0;
            padding: 0;
        }
        
        .page-link {
            display: block;
            padding: 8px 12px;
            border: 1px solid #ddd;
            background: white;
            color: #3498db;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .page-link:hover {
            background: #f1f5f9;
            border-color: #3498db;
        }
        
        .page-item.active .page-link {
            background: #3498db;
            color: white;
            border-color: #3498db;
        }
        
        .page-item.disabled .page-link {
            color: #94a3b8;
            background: #f8fafc;
            cursor: not-allowed;
            border-color: #e2e8f0;
        }
        
        .pagination-info {
            color: #64748b;
            font-size: 14px;
            margin: 0 15px;
        }
        
        .no-data {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
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
        
        /* Search box styling */
        .search-box {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .form-control {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: border-color 0.2s;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            background: #f8fafc;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            color: #475569;
            border-bottom: 2px solid #e2e8f0;
        }
        
        td {
            padding: 12px 15px;
            border-bottom: 1px solid #e2e8f0;
            color: #475569;
        }
        
        tr:hover {
            background: #f8fafc;
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
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active" style="display: block;">
            <%-- Display success message from session --%>
            <% if (session.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success">
                    <%= session.getAttribute("successMessage") %>
                </div>
                <% session.removeAttribute("successMessage"); %>
            <% } %>
            
            <%-- Display error messages --%>
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>
            
            <h1 class="page-title">Manage Users</h1>
            
            <div class="stats-cards">
                <div class="stat-card">
                    <h3>Total Users</h3>
                    <div class="number"><%= totalUsers %></div>
                </div>
                <div class="stat-card">
                    <h3>Admins</h3>
                    <div class="number">
                        <% 
                            int adminCount = 0;
                            for (User u : allUsers) {
                                if ("admin".equalsIgnoreCase(u.getRole())) {
                                    adminCount++;
                                }
                            }
                        %>
                        <%= adminCount %>
                    </div>
                </div>
                <div class="stat-card">
                    <h3>Regular Users</h3>
                    <div class="number">
                        <% 
                            int userCount = 0;
                            for (User u : allUsers) {
                                if ("user".equalsIgnoreCase(u.getRole())) {
                                    userCount++;
                                }
                            }
                        %>
                        <%= userCount %>
                    </div>
                </div>
                <div class="stat-card">
                    <h3>Total Points</h3>
                    <div class="number">
                        <% 
                            int totalPoints = 0;
                            for (User u : allUsers) {
                                totalPoints += u.getCurrentPoints();
                            }
                        %>
                        <%= totalPoints %>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <h3>Users List</h3>
                
                <div class="table-header">
                    <div class="search-box">
                        <input type="text" 
                               placeholder="Search users..." 
                               id="searchInput" 
                               class="form-control" 
                               style="width: 250px;">
                        <div class="pagination-info">
                            Showing <%= startIndex + 1 %>-<%= endIndex %> of <%= totalUsers %> users
                        </div>
                    </div>
                    <a href="AdminUserServlet?action=add" class="btn btn-primary">
                        <i class="fas fa-plus" style="margin-right: 8px;"></i>
                        Add New User
                    </a>
                </div>
                
                <% if (totalUsers > 0) { %>
                <div class="table-container">
                    <table id="usersTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Phone</th>
                                <th>Role</th>
                                <th>Points</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                if (pageUsers != null) {
                                    for (User user : pageUsers) { 
                                        String roleClass = "role-user";
                                        if ("admin".equalsIgnoreCase(user.getRole())) {
                                            roleClass = "role-admin";
                                        }
                                        
                                        // Get deletable status from request attribute
                                        boolean isDeletable = true; // Default
                                        Object deletableAttr = request.getAttribute("userDeletable_" + user.getUserId());
                                        if (deletableAttr != null) {
                                            isDeletable = (Boolean) deletableAttr;
                                        }
                            %>
                            <tr>
                                <td>USR-<%= String.format("%04d", user.getUserId()) %></td>
                                <td><%= user.getName() %></td>
                                <td><%= user.getEmail() %></td>
                                <td><%= user.getPhone() != null && !user.getPhone().isEmpty() ? user.getPhone() : "N/A" %></td>
                                <td>
                                    <span class="role-badge <%= roleClass %>">
                                        <%= user.getRole() != null ? user.getRole().toUpperCase() : "USER" %>
                                    </span>
                                </td>
                                <td>
                                    <span class="points-badge">
                                        <%= user.getCurrentPoints() %> pts
                                    </span>
                                </td>
                                <td style="white-space: nowrap;">
                                    <div class="action-buttons">
                                        <!-- View Button -->
                                        <a href="AdminUserServlet?action=view&id=<%= user.getUserId() %>" 
                                           class="action-btn btn-view" 
                                           title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>

                                        <!-- Edit Button -->
                                        <a href="AdminUserServlet?action=edit&id=<%= user.getUserId() %>" 
                                           class="action-btn btn-edit" 
                                           title="Edit User">
                                            <i class="fas fa-pen"></i>
                                        </a>

                                        <!-- Delete Button -->
                                        <% if (isDeletable && user.getUserId() != loggedInUser.getUserId()) { %>
                                        <form action="AdminUserServlet" method="POST" 
                                              onsubmit="return confirmDelete('<%= user.getName() %>')"
                                              style="display: inline;">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= user.getUserId() %>">
                                            <button type="submit" class="action-btn btn-danger" title="Delete User">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                        <% } else if (user.getUserId() == loggedInUser.getUserId()) { %>
                                        <button class="action-btn btn-disabled" 
                                                title="Cannot delete your own account"
                                                style="cursor: not-allowed; opacity: 0.5; background: #e5e7eb; color: #9ca3af;">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                        <% } else { %>
                                        <button class="action-btn btn-disabled" 
                                                title="Cannot delete - user has active records"
                                                style="cursor: not-allowed; opacity: 0.5; background: #e5e7eb; color: #9ca3af;">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <% 
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
                    
                    <%-- Pagination Controls --%>
                    <% if (totalPages > 1) { %>
                    <div class="pagination-container">
                        <nav>
                            <ul class="pagination">
                                <%-- Previous page link --%>
                                <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
                                    <a class="page-link" 
                                       href="AdminUserServlet?page=<%= currentPage - 1 %>"
                                       aria-label="Previous">
                                        <i class="fas fa-chevron-left"></i>
                                    </a>
                                </li>
                                
                                <%-- Page numbers --%>
                                <% 
                                    int startPage = Math.max(1, currentPage - 2);
                                    int endPage = Math.min(totalPages, currentPage + 2);
                                    
                                    // Show first page if not in range
                                    if (startPage > 1) {
                                %>
                                <li class="page-item">
                                    <a class="page-link" href="AdminUserServlet?page=1">1</a>
                                </li>
                                <% if (startPage > 2) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                                <% } } %>
                                
                                <% for (int i = startPage; i <= endPage; i++) { %>
                                <li class="page-item <%= i == currentPage ? "active" : "" %>">
                                    <a class="page-link" href="AdminUserServlet?page=<%= i %>"><%= i %></a>
                                </li>
                                <% } %>
                                
                                <%-- Show last page if not in range --%>
                                <% if (endPage < totalPages) { %>
                                <% if (endPage < totalPages - 1) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                                <% } %>
                                <li class="page-item">
                                    <a class="page-link" href="AdminUserServlet?page=<%= totalPages %>"><%= totalPages %></a>
                                </li>
                                <% } %>
                                
                                <%-- Next page link --%>
                                <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                                    <a class="page-link" 
                                       href="AdminUserServlet?page=<%= currentPage + 1 %>"
                                       aria-label="Next">
                                        <i class="fas fa-chevron-right"></i>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                        
                        <div class="pagination-info">
                            Page <%= currentPage %> of <%= totalPages %>
                        </div>
                    </div>
                    <% } %>
                    
                <% } else { %>
                    <div class="no-data">
                        <i class="fas fa-users" style="font-size: 48px; margin-bottom: 20px; color: #ccc; display: block;"></i>
                        <p style="font-size: 16px; margin-bottom: 20px;">No users found in the system.</p>
                        <a href="AdminUserServlet?action=add" class="btn btn-primary" style="padding: 10px 20px;">
                            <i class="fas fa-plus" style="margin-right: 8px;"></i>
                            Add First User
                        </a>
                    </div>
                <% } %>
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

        // Search functionality
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('keyup', function() {
                    const searchTerm = this.value.toLowerCase();
                    const table = document.getElementById('usersTable');
                    
                    if (table) {
                        const rows = table.getElementsByTagName('tr');
                        let visibleCount = 0;
                        
                        for (let i = 1; i < rows.length; i++) {
                            const row = rows[i];
                            const cells = row.getElementsByTagName('td');
                            let found = false;
                            
                            // Check each cell in the row (skip actions cell)
                            for (let j = 0; j < cells.length - 1; j++) {
                                const cellText = cells[j].textContent.toLowerCase();
                                if (cellText.includes(searchTerm)) {
                                    found = true;
                                    break;
                                }
                            }
                            
                            if (found) {
                                row.style.display = '';
                                visibleCount++;
                            } else {
                                row.style.display = 'none';
                            }
                        }
                        
                        // Update pagination info for search results
                        const paginationInfo = document.querySelector('.pagination-info');
                        if (paginationInfo && visibleCount > 0) {
                            paginationInfo.textContent = 'Showing ' + visibleCount + ' result(s) for "' + searchTerm + '"';
                        } else if (paginationInfo) {
                            paginationInfo.textContent = 'No results found for "' + searchTerm + '"';
                        }
                    }
                });
            }
        });
    </script>
</body>
</html>