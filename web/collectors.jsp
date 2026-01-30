<%@page import="com.recyclehub.model.User"%>
<%@page import="com.recyclehub.model.Collector"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Check if user is admin
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Get collectors list from request attribute
    List<Collector> allCollectors = (List<Collector>) request.getAttribute("collectors");
    if (allCollectors == null) {
        allCollectors = new ArrayList<Collector>();
    }
    
    // Pagination parameters
    int pageSize = 10; // 10 collectors per page
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
    int totalCollectors = allCollectors.size();
    int totalPages = (int) Math.ceil((double) totalCollectors / pageSize);
    
    // Ensure current page is within bounds
    if (currentPage < 1) currentPage = 1;
    if (currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    
    // Get sublist for current page
    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalCollectors);
    List<Collector> pageCollectors = null;
    
    if (startIndex < totalCollectors) {
        pageCollectors = allCollectors.subList(startIndex, endIndex);
    } else {
        pageCollectors = new ArrayList<Collector>();
    }
    
    // Debug output
    System.out.println("JSP DEBUG: Total collectors = " + totalCollectors);
    System.out.println("JSP DEBUG: Current page = " + currentPage);
    System.out.println("JSP DEBUG: Total pages = " + totalPages);
    System.out.println("JSP DEBUG: Page collectors size = " + pageCollectors.size());
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Manage Collectors</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* Keep existing styles but modify table styling */
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
        
        /* Table styling to match dashboard */
        
        
        /* Status badges - match dashboard styling */
        .status-badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-weight: bold;
            font-size: 0.85em;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .status-available {
            background-color: #28a745;
            color: white;
        }
        .status-busy {
            background-color: #dc3545;
            color: white;
        }
        .status-leave {
            background-color: #ffc107;
            color: black;
        }
        
        /* Action buttons to match dashboard */
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
        
        .btn-sm {
            padding: 6px 12px;
            font-size: 12px;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.2s;
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
        
        .page-item {
            margin: 0;
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
        
        /* Form styling for inline forms */
        form[style*="display: inline"] {
            display: inline;
            margin: 0;
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
        
        /* Action button tooltips */
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
            <a href="AdminDashboardServlet" class="logo">
                <span>♻️</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul id="nav-menu">
                    <li><a href="AdminDashboardServlet">Dashboard</a></li>
                    <li><a href="AllRequestsServlet">All Requests</a></li>
                    <li><a href="AdminCollectorServlet" style="font-weight: bold; background-color: rgba(255, 255, 255, 0.1);">Manage Collectors</a></li>
                    <li><a href="AdminUserServlet">Manage Users</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= user.getName() %></span>
                <span class="user-role">Admin</span>
                <a href="LogoutServlet" class="btn btn-danger">Logout</a>
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
            
            <h1 class="page-title">Manage Collectors</h1>
            
            <div class="stats-cards">
                <div class="stat-card">
                    <h3>Total Collectors</h3>
                    <div class="number"><%= totalCollectors %></div>
                </div>
                <div class="stat-card">
                    <h3>Active Collectors</h3>
                    <div class="number">
                        <% 
                            int activeCount = 0;
                            for (Collector c : allCollectors) {
                                if ("Available".equalsIgnoreCase(c.getStatus())) {
                                    activeCount++;
                                }
                            }
                        %>
                        <%= activeCount %>
                    </div>
                </div>
                <div class="stat-card">
                    <h3>On Duty</h3>
                    <div class="number">
                        <% 
                            int onDutyCount = 0;
                            for (Collector c : allCollectors) {
                                if (!"On Leave".equalsIgnoreCase(c.getStatus())) {
                                    onDutyCount++;
                                }
                            }
                        %>
                        <%= onDutyCount %>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <h3>Collectors List</h3>
                
                <div class="table-header">
                    
                    <div class="search-box">
                        <input type="text" 
                               placeholder="Search collectors..." 
                               id="searchInput" 
                               class="form-control" 
                               style="width: 250px;">
                        <div class="pagination-info">
                            Showing <%= startIndex + 1 %>-<%= endIndex %> of <%= totalCollectors %> collectors
                        </div>
                    </div>
                        <a href="addCollector.jsp" class="btn btn-primary">
                    <i class="fas fa-plus" style="margin-right: 8px;"></i>
                    Add New Collector
                </a>
                        
                </div>
                
                <% if (totalCollectors > 0) { %>
                <div class="table-container">
                    <table id="collectorsTable">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Phone</th>
                                <th>Plate Number</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                if (pageCollectors != null) {
                                    for (Collector collector : pageCollectors) { 
                                        String statusClass = "status-pending";
                                        if ("Available".equalsIgnoreCase(collector.getStatus())) {
                                            statusClass = "status-available";
                                        } else if ("Busy".equalsIgnoreCase(collector.getStatus())) {
                                            statusClass = "status-busy";
                                        } else if ("On Leave".equalsIgnoreCase(collector.getStatus())) {
                                            statusClass = "status-leave";
                                        }
                                        
                                        String statusText = collector.getStatus() != null ? collector.getStatus() : "Available";
                            %>
                            <tr>
                                <td>COL-<%= String.format("%04d", collector.getCollectorId()) %></td>
                                <td><%= collector.getName() %></td>
                                <td><%= collector.getPhone() %></td>
                                <td><%= collector.getPlateNumber() != null && !collector.getPlateNumber().isEmpty() ? collector.getPlateNumber() : "N/A" %></td>
                                <td>
                                    <span class="status-badge <%= statusClass %>">
                                        <%= statusText %>
                                    </span>
                                </td>
                                <td style="white-space: nowrap;">
                                    <div class="action-buttons">
                                        <!-- View Button -->
                                        <a href="AdminCollectorServlet?action=view&id=<%= collector.getCollectorId() %>" 
                                           class="action-btn btn-view" 
                                           title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </a>

                                        <!-- Edit Button -->
                                        <a href="AdminCollectorServlet?action=edit&id=<%= collector.getCollectorId() %>" 
                                           class="action-btn btn-edit" 
                                           title="Edit Collector">
                                            <i class="fas fa-pen"></i>
                                        </a>

                                        <!-- Delete Button -->
        <!-- Delete Button - Check deletable status from collector object -->
        <% if (collector.isDeletable()) { %>
        <form action="AdminCollectorServlet" method="POST" 
              onsubmit="return confirmDelete('<%= collector.getName() %>')"
              style="display: inline;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" value="<%= collector.getCollectorId() %>">
            <button type="submit" class="action-btn btn-danger" title="Delete Collector">
                <i class="fas fa-trash"></i>
            </button>
        </form>
        <% } else { %>
        <button class="action-btn btn-disabled" 
                title="Cannot delete - collector has active assignments"
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
                                       href="AdminCollectorServlet?page=<%= currentPage - 1 %>"
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
                                    <a class="page-link" href="AdminCollectorServlet?page=1">1</a>
                                </li>
                                <% if (startPage > 2) { %>
                                <li class="page-item disabled">
                                    <span class="page-link">...</span>
                                </li>
                                <% } } %>
                                
                                <% for (int i = startPage; i <= endPage; i++) { %>
                                <li class="page-item <%= i == currentPage ? "active" : "" %>">
                                    <a class="page-link" href="AdminCollectorServlet?page=<%= i %>"><%= i %></a>
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
                                    <a class="page-link" href="AdminCollectorServlet?page=<%= totalPages %>"><%= totalPages %></a>
                                </li>
                                <% } %>
                                
                                <%-- Next page link --%>
                                <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                                    <a class="page-link" 
                                       href="AdminCollectorServlet?page=<%= currentPage + 1 %>"
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
                        <p style="font-size: 16px; margin-bottom: 20px;">No collectors found in the system.</p>
                        <a href="addCollector.jsp" class="btn btn-primary" style="padding: 10px 20px;">
                            <i class="fas fa-plus" style="margin-right: 8px;"></i>
                            Add First Collector
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
        
        function confirmDelete(collectorName) {
    return confirm('Are you sure you want to delete collector "' + collectorName + '"?\n\nThis action cannot be undone.');
} 

        // Search functionality
        document.addEventListener('DOMContentLoaded', function() {
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                searchInput.addEventListener('keyup', function() {
                    const searchTerm = this.value.toLowerCase();
                    const table = document.getElementById('collectorsTable');
                    
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
                        }
                    }
                });
            }
            
            // Add tooltips for action buttons
            const actionButtons = document.querySelectorAll('.action-btn');
            actionButtons.forEach(btn => {
                if (btn.title) {
                    btn.addEventListener('mouseenter', function(e) {
                        const tooltip = document.createElement('div');
                        tooltip.className = 'tooltip';
                        tooltip.textContent = this.title;
                        tooltip.style.position = 'absolute';
                        tooltip.style.background = '#333';
                        tooltip.style.color = '#fff';
                        tooltip.style.padding = '5px 10px';
                        tooltip.style.borderRadius = '4px';
                        tooltip.style.fontSize = '12px';
                        tooltip.style.zIndex = '1000';
                        tooltip.style.whiteSpace = 'nowrap';
                        
                        const rect = this.getBoundingClientRect();
                        tooltip.style.top = (rect.top - 30) + 'px';
                        tooltip.style.left = (rect.left + rect.width/2 - tooltip.offsetWidth/2) + 'px';
                        
                        document.body.appendChild(tooltip);
                        this._tooltip = tooltip;
                    });
                    
                    btn.addEventListener('mouseleave', function() {
                        if (this._tooltip) {
                            document.body.removeChild(this._tooltip);
                            this._tooltip = null;
                        }
                    });
                }
            });
        });
    </script>
</body>
</html>