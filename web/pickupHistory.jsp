<%@page import="com.recyclehub.model.User"%>
<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page import="com.recyclehub.model.PickupDetails"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get pickup history from request attribute (set by servlet)
    List<PickupRequest> pickupHistory = (List<PickupRequest>) request.getAttribute("historyList");
    // Get pickup details if available
    List<PickupDetails> pickupDetailsList = (List<PickupDetails>) request.getAttribute("pickupDetailsList");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Pickup History</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="DashboardServlet" class="logo">
                <span>♻️</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul>
                    <li><a href="DashboardServlet">Dashboard</a></li>
                    <li><a href="requestPickup.jsp">Request Pickup</a></li>
                    <li><a href="PickupHistoryServlet">History</a></li>
                    <li><a href="rewards.jsp">Rewards</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= user.getName() != null ? user.getName() : "User" %></span>
                <span id="user-role" class="user-role">User</span>
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">My Pickup History</h1>
            
            <div class="card">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Request ID</th>
                                <th>Pickup Date</th>
                                <th>Materials</th>
                                <th>Weight (kg)</th>
                                <th>CO₂ Saved</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="pickup-history-table">
                            <% 
                            if (pickupHistory != null && !pickupHistory.isEmpty()) {
                                for (PickupRequest pickup : pickupHistory) {
                                    // Calculate total weight for this pickup
                                    double totalWeight = 0.0;
                                    String materials = "N/A";
                                    
                                    // If we have details list, calculate weight and get materials
                                    if (pickupDetailsList != null) {
                                        StringBuilder materialsBuilder = new StringBuilder();
                                        for (PickupDetails detail : pickupDetailsList) {
                                            if (detail.getRequestId() == pickup.getRequestId()) {
                                                totalWeight += detail.getWeight();
                                                if (materialsBuilder.length() > 0) {
                                                    materialsBuilder.append(", ");
                                                }
                                                materialsBuilder.append(detail.getCategory());
                                            }
                                        }
                                        materials = materialsBuilder.toString();
                                    }
                                    
                                    // Calculate CO₂ saved (1.33 kg CO₂ per kg recycled)
                                    double co2Saved = Math.round(totalWeight * 1.33 * 10.0) / 10.0;
                                    
                                    // Status class for styling
                                    String statusClass = pickup.getStatus() != null ? 
                                        pickup.getStatus().toLowerCase().replace(" ", "-") : "default";
                            %>
                            <tr>
                                <td>REQ-<%= String.format("%04d", pickup.getRequestId()) %></td>
                                <td><%= pickup.getPickupDate() != null ? pickup.getPickupDate() : "N/A" %></td>
                                <td><%= materials %></td>
                                <td><%= totalWeight > 0 ? String.format("%.1f", totalWeight) : "N/A" %></td>
                                <td><%= co2Saved > 0 ? String.format("%.1f", co2Saved) : "N/A" %></td>
                                <td><span class="status-badge status-<%= statusClass %>"><%= pickup.getStatus() %></span></td>
                                <td>
                                    <a href="PickupDetailsServlet?id=<%= pickup.getRequestId() %>" class="btn">View Details</a>
                                </td>
                            </tr>
                            <% 
                                }
                            } else { 
                            %>
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 40px;">
                                    <div style="font-size: 48px; margin-bottom: 20px;">📋</div>
                                    <h3>No Pickup History</h3>
                                    <p>You haven't scheduled any pickups yet.</p>
                                    <a href="requestPickup.jsp" class="btn btn-primary" style="margin-top: 20px;">
                                        Schedule Your First Pickup
                                    </a>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    
                    <% if (pickupHistory != null && !pickupHistory.isEmpty()) { %>
                    <div style="margin-top: 20px; padding: 15px; background: #e8f5e8; border-radius: 8px; display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <strong>Total Records:</strong> <%= pickupHistory.size() %> pickup<%= pickupHistory.size() != 1 ? "s" : "" %>
                        </div>
                        <div>
                            <strong>Completed:</strong> 
                            <% 
                                long completedCount = 0;
                                if (pickupHistory != null) {
                                    for (PickupRequest p : pickupHistory) {
                                        if ("Completed".equalsIgnoreCase(p.getStatus())) {
                                            completedCount++;
                                        }
                                    }
                                }
                            %>
                            <%= completedCount %>
                        </div>
                        <div>
                            <a href="DashboardServlet" class="btn" style="padding: 8px 15px;">Back to Dashboard</a>
                        </div>
                    </div>
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
        function logout() {
            if (confirm('Are you sure you want to logout?')) {
                window.location.href = 'LogoutServlet';
            }
        }
        
        // Add table row hover effects
        document.addEventListener('DOMContentLoaded', function() {
            const tableRows = document.querySelectorAll('table tbody tr');
            tableRows.forEach(row => {
                row.addEventListener('mouseenter', function() {
                    this.style.backgroundColor = '#f8f9fa';
                    this.style.transition = 'background-color 0.2s ease';
                });
                row.addEventListener('mouseleave', function() {
                    this.style.backgroundColor = '';
                });
            });
            
            // Add click effect to action buttons
            const actionButtons = document.querySelectorAll('.btn');
            actionButtons.forEach(button => {
                button.addEventListener('click', function(e) {
                    // Add subtle click effect
                    this.style.transform = 'scale(0.98)';
                    setTimeout(() => {
                        this.style.transform = 'scale(1)';
                    }, 150);
                });
            });
            
            // Add sorting functionality (optional enhancement)
            const tableHeaders = document.querySelectorAll('table thead th');
            tableHeaders.forEach((header, index) => {
                if (index < 6) { // Don't add sorting to Actions column
                    header.style.cursor = 'pointer';
                    header.addEventListener('click', function() {
                        sortTable(index);
                    });
                    
                    // Add sort indicator
                    const sortIndicator = document.createElement('span');
                    sortIndicator.innerHTML = ' ↕';
                    sortIndicator.style.fontSize = '12px';
                    sortIndicator.style.opacity = '0.5';
                    header.appendChild(sortIndicator);
                }
            });
        });
        
        // Simple table sorting function
        function sortTable(columnIndex) {
            const table = document.querySelector('table');
            const tbody = table.querySelector('tbody');
            const rows = Array.from(tbody.querySelectorAll('tr'));
            
            // Skip if no data rows
            if (rows.length <= 1 || rows[0].cells[0].colSpan > 1) return;
            
            // Get current sort order
            const currentSort = table.getAttribute('data-sort') || '';
            const [currentColumn, currentDirection] = currentSort.split('-');
            let newDirection = 'asc';
            
            if (parseInt(currentColumn) === columnIndex) {
                newDirection = currentDirection === 'asc' ? 'desc' : 'asc';
            }
            
            // Sort rows
            rows.sort((a, b) => {
                const aValue = a.cells[columnIndex].textContent.trim();
                const bValue = b.cells[columnIndex].textContent.trim();
                
                // Try to parse as number
                const aNum = parseFloat(aValue);
                const bNum = parseFloat(bValue);
                
                let comparison = 0;
                if (!isNaN(aNum) && !isNaN(bNum)) {
                    comparison = aNum - bNum;
                } else {
                    comparison = aValue.localeCompare(bValue);
                }
                
                return newDirection === 'asc' ? comparison : -comparison;
            });
            
            // Re-append sorted rows
            rows.forEach(row => tbody.appendChild(row));
            
            // Update sort indicator
            table.setAttribute('data-sort', `${columnIndex}-${newDirection}`);
            
            // Update sort indicators in headers
            const headers = table.querySelectorAll('thead th');
            headers.forEach((header, index) => {
                let indicator = header.querySelector('span');
                if (!indicator) {
                    indicator = document.createElement('span');
                    indicator.style.fontSize = '12px';
                    header.appendChild(indicator);
                }
                
                if (index === columnIndex) {
                    indicator.innerHTML = newDirection === 'asc' ? ' ↑' : ' ↓';
                    indicator.style.opacity = '1';
                } else {
                    indicator.innerHTML = ' ↕';
                    indicator.style.opacity = '0.5';
                }
            });
            
            // Show sort notification
            showSortNotification(columnIndex, newDirection);
        }
        
        function showSortNotification(columnIndex, direction) {
            const columnNames = [
                'Request ID', 'Pickup Date', 'Materials', 'Weight', 'CO₂ Saved', 'Status'
            ];
            
            // Create notification
            const notification = document.createElement('div');
            notification.style.cssText = `
                position: fixed;
                bottom: 20px;
                right: 20px;
                background: #28a745;
                color: white;
                padding: 10px 15px;
                border-radius: 5px;
                box-shadow: 0 4px 8px rgba(0,0,0,0.1);
                z-index: 1000;
                animation: slideIn 0.3s ease;
            `;
            
            notification.innerHTML = `
                Sorted by <strong>${columnNames[columnIndex]}</strong> 
                (${direction == 'asc' ? 'ascending' : 'descending'})
            `;
            
            document.body.appendChild(notification);
            
            // Remove after 2 seconds
            setTimeout(() => {
                notification.style.animation = 'slideOut 0.3s ease';
                setTimeout(() => notification.remove(), 300);
            }, 2000);
        }
        
        // Add CSS for animations
        const style = document.createElement('style');
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>