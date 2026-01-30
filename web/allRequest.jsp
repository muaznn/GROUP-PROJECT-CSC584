<%@page import="com.recyclehub.model.User"%>
<%@page import="com.recyclehub.model.Collector"%>
<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    List reqList = (List) request.getAttribute("pickupRequests");
    String currentTab = (String) request.getAttribute("currentTab");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Requests</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        /* Minimalist Action Buttons */
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
            margin: 0 3px;
            transition: background 0.2s;
            font-size: 14px;
        }

        .btn-view { background: #e2e8f0; color: #475569; }
        .btn-view:hover { background: #cbd5e1; color: #1e293b; }

        .btn-edit { background: #dbeafe; color: #2563eb; }
        .btn-edit:hover { background: #bfdbfe; color: #1d4ed8; }

        .btn-delete { background: #fee2e2; color: #dc2626; }
        .btn-delete:hover { background: #fecaca; color: #b91c1c; }

        /* Tooltip trick */
        .action-btn[title]:hover::after {
            content: attr(title);
            position: absolute;
            background: #333;
            color: #fff;
            padding: 4px 8px;
            font-size: 11px;
            border-radius: 4px;
            transform: translateY(-25px);
            white-space: nowrap;
        }
    </style>
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
                    <li><a href="AdminUserServlet">Manage Users</a></li>
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
        <div class="page-container active">
            <h1 class="page-title">Pickup Requests</h1>
            
            <div class="tabs">
                <a href="AllRequestsServlet?tab=all" class="tab <%= "all".equals(currentTab) ? "active" : "" %>">All</a>
                <a href="AllRequestsServlet?tab=pending" class="tab <%= "pending".equals(currentTab) ? "active" : "" %>">Pending</a>
                <a href="AllRequestsServlet?tab=scheduled" class="tab <%= "scheduled".equals(currentTab) ? "active" : "" %>">Scheduled</a>
                <a href="AllRequestsServlet?tab=completed" class="tab <%= "completed".equals(currentTab) ? "active" : "" %>">Completed</a>
            </div>
            
            <div class="tab-content active" style="display: block;">
                <div class="card">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>User</th>
                                    <th>Pickup Date</th>
                                    <th>Status</th>
                                    <th>Collector</th>
                                    <th>Actions</th> </tr>
                            </thead>
                            <tbody>
                                <% 
                                if (reqList != null && !reqList.isEmpty()) {
                                    for (Object o : reqList) {
                                        PickupRequest p = (PickupRequest) o;
                                        String status = p.getStatus() != null ? p.getStatus() : "Unknown";
                                        String statusClass = status.toLowerCase();
                                %>
                                <tr>
                                    <td>#<%= String.format("%04d", p.getRequestId()) %></td>
                                    <td><%= p.getUserName() %></td>
                                    <td><%= p.getRequestDate() %></td>
                                    <td><span class="status-badge status-<%= statusClass %>"><%= status %></span></td>
                                    <td>
                                        <%= (p.getCollectorName() != null) ? p.getCollectorName() : "<span style='color:#ccc'>--</span>" %>
                                    </td>
                                    
                                    <td style="white-space: nowrap;">
                                        <a href="AdminViewRequestServlet?id=<%= p.getRequestId() %>" class="action-btn btn-view" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>

                                        <% if (!"Completed".equalsIgnoreCase(status) && !"Cancelled".equalsIgnoreCase(status)) { %>
                                            <a href="AdminEditRequestServlet?id=<%= p.getRequestId() %>" class="action-btn btn-edit" title="Edit / Assign">
                                                <i class="fas fa-pen"></i>
                                            </a>
                                        <% } %>

                                        </td>
                                </tr>
                                <% 
                                    } 
                                } else { 
                                %>
                                <tr>
                                    <td colspan="6" style="text-align:center; padding: 40px; color: #666;">
                                        <i class="fas fa-inbox" style="font-size: 24px; margin-bottom: 10px; display:block;"></i>
                                        No requests found.
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>