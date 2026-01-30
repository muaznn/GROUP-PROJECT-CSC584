<%@page import="com.recyclehub.model.User"%>
<%@page import="java.util.List"%>
<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Admin Dashboard</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Existing styles */
        .status-badge { 
            padding: 5px 10px; 
            border-radius: 15px; 
            color: white; 
            font-weight: bold; 
            font-size: 0.9em; 
        }
        .status-completed { background-color: #28a745; }
        .status-pending { background-color: #ffc107; color: black; }
        .status-cancelled { background-color: #dc3545; }
        .status-assigned { background-color: #17a2b8; }
        
        /* Action button styles matching allrequests.jsp */
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

        .btn-disabled { 
            background: #f1f5f9; 
            color: #94a3b8; 
            cursor: not-allowed;
            opacity: 0.6;
        }

        /* Tooltip */
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
            z-index: 1000;
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
                    <li><a href="AdminUserServlet">Manage User</a></li>
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
            <h1 class="page-title">Admin Dashboard</h1>
            
            <div class="admin-controls">
                <a href="AllRequestsServlet" class="btn btn-primary">
                    👁️ View All Requests
                </a>
            </div>

            <div class="admin-stats">
                <div class="admin-stat">
                    <div class="stat-value" id="total-requests">
                        <%= request.getAttribute("totalReq") %>
                    </div>
                    <div class="stat-label">Total Requests</div>
                </div>
                <div class="admin-stat">
                    <div class="stat-value" id="pending-requests">
                        <%= request.getAttribute("pendingReq") %>
                    </div>
                    <div class="stat-label">Pending</div>
                </div>
                <div class="admin-stat">
                    <div class="stat-value" id="active-collectors">
                        <%= request.getAttribute("activeCollectors") %>
                    </div>
                    <div class="stat-label">Active Collectors</div>
                </div>
                <div class="admin-stat">
                    <div class="stat-value" id="monthly-recycled">
                        <%= request.getAttribute("monthlyWeight") %> kg
                    </div>
                    <div class="stat-label">This Month</div>
                </div>
            </div>

            <div class="card">
                <h3>Recent Pickup Requests</h3>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>User Name</th>
                                <th>Date</th>
                                <th>Status</th> 
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="admin-requests-table">
                            <% 
                                List<PickupRequest> list = (List<PickupRequest>) request.getAttribute("recentList");
                                if (list != null && !list.isEmpty()) {
                                    for (PickupRequest p : list) {
                                        // CSS logic
                                        String statusClass = "status-pending";
                                        if ("Completed".equalsIgnoreCase(p.getStatus())) statusClass = "status-completed";
                                        else if ("Cancelled".equalsIgnoreCase(p.getStatus())) statusClass = "status-cancelled";
                                        else if ("Assigned".equalsIgnoreCase(p.getStatus())) statusClass = "status-assigned";
                                        
                                        String status = p.getStatus() != null ? p.getStatus() : "Unknown";
                            %>
                            <tr>
                                <td>REQ-<%= String.format("%04d", p.getRequestId()) %></td>
                                <td><%= p.getUserName() %></td>
                                <td><%= p.getRequestDate() %></td>
                                <td>
                                    <span class="status-badge <%= statusClass %>">
                                        <%= status %>
                                    </span>
                                </td>
                                <td style="white-space: nowrap;">
                                    <!-- View Button - Always shown -->
                                    <a href="AdminViewRequestServlet?id=<%= p.getRequestId() %>" 
                                       class="action-btn btn-view" 
                                       title="View Details">
                                        <i class="fas fa-eye"></i>
                                    </a>

                                    <!-- Edit Button - Only show if not completed/cancelled (matching allrequests.jsp) -->
                                    <% if (!"Completed".equalsIgnoreCase(status) && !"Cancelled".equalsIgnoreCase(status)) { %>
                                        <a href="AdminEditRequestServlet?id=<%= p.getRequestId() %>" 
                                           class="action-btn btn-edit" 
                                           title="Edit / Assign">
                                            <i class="fas fa-pen"></i>
                                        </a>
                                    <% } else { %>
                                        <!-- Show disabled edit button -->
                                        <span class="action-btn btn-disabled" title="Cannot edit completed/cancelled requests">
                                            <i class="fas fa-pen"></i>
                                        </span>
                                    <% } %>
                                </td>
                            </tr>
                            <% 
                                    } 
                                } else {
                            %>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 20px;">
                                    <i class="fas fa-inbox" style="font-size: 24px; margin-bottom: 10px; display:block; color: #666;"></i>
                                    No recent requests found.
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
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
                &copy; 2026 RecycleHub. All rights reserved.
            </div>
        </div>
    </footer>

</body>
</html>