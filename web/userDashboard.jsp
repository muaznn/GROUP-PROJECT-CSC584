<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page import="com.recyclehub.model.User"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Get user from session
    User user = (User) session.getAttribute("user");
    if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get data from request attributes
    List<PickupRequest> pickupRequests = (List<PickupRequest>) request.getAttribute("pickupRequests");
    Integer totalPickups = (Integer) request.getAttribute("totalPickups");
    Double totalWeight = (Double) request.getAttribute("totalWeight");
    Integer totalPoints = (Integer) request.getAttribute("totalPoints");
    
    // Calculate CO2 saved (1.33 kg CO2 per kg recycled)
    Double co2Saved = 0.0;
    if (totalWeight != null && totalWeight > 0) {
        co2Saved = Math.round(totalWeight * 1.33 * 10.0) / 10.0;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - User Dashboard</title>
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
                    <li><a href="DashboardServlet" class="active">Dashboard</a></li>
                    <li><a href="requestPickup.jsp">Request Pickup</a></li>
                    <li><a href="PickupHistoryServlet">History</a></li>
                    <li><a href="rewards.jsp">Rewards</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= user.getName() %></span>
                <span id="user-role" class="user-role">User</span>
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">Dashboard Overview</h1>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value" id="total-pickups">
                        <%= (totalPickups != null) ? totalPickups : 0 %>
                    </div>
                    <div class="stat-label">Total Pickups</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="total-weight">
                        <%= String.format("%.1f", (totalWeight != null) ? totalWeight : 0.0) %> kg
                    </div>
                    <div class="stat-label">Recycled</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="co2-saved">
                        <%= String.format("%.1f", co2Saved) %> kg
                    </div>
                    <div class="stat-label">CO₂ Saved</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="user-points">
                        <%= (totalPoints != null) ? totalPoints : user.getCurrentPoints() %>
                    </div>
                    <div class="stat-label">Eco Points</div>
                </div>
            </div>

            <div class="quick-actions">
                <a href="requestPickup.jsp" class="btn btn-primary">
                    📅 Schedule New Pickup
                </a>
                <a href="PickupHistoryServlet" class="btn btn-secondary">
                    📋 View Pickup History
                </a>
                <a href="profile.jsp" class="btn">
                    👤 Update Profile
                </a>
                <a href="rewards.jsp" class="btn btn-secondary">
                    🏆 View Rewards
                </a>
            </div>

            <div class="card">
                <h3>Upcoming Pickups</h3>
                <div class="pickup-list" id="upcoming-pickups">
                    <%
                        boolean hasUpcoming = false;
                        if (pickupRequests != null && !pickupRequests.isEmpty()) {
                            for (PickupRequest p : pickupRequests) {
                                if ("Pending".equalsIgnoreCase(p.getStatus()) || 
                                    "Scheduled".equalsIgnoreCase(p.getStatus()) ||
                                    "Assigned".equalsIgnoreCase(p.getStatus())) {
                                    hasUpcoming = true;
                                    String statusClass = p.getStatus().toLowerCase().replace(" ", "-");
                    %>
                    <div class="pickup-item">
                        <div>
<strong><%= p.getPickupDate() %> (<%= p.getPickupTime() != null ? p.getPickupTime() : "Anytime" %>)</strong>                            <span>Pickup Request #<%= String.format("%04d", p.getRequestId()) %></span>
                        </div>
                        <span class="status-badge status-<%= statusClass %>"><%= p.getStatus() %></span>
                    </div>
                    <%
                                }
                            }
                        }
                        if (!hasUpcoming) {
                    %>
                    <p>No upcoming pickups. <a href="requestPickup.jsp">Schedule one now!</a></p>
                    <% } %>
                </div>
            </div>

            <div class="card">
                <h3>Recent Activity</h3>
                <div id="recent-activity">
                    <%
                        boolean hasActivity = false;
                        if (pickupRequests != null && !pickupRequests.isEmpty()) {
                            // Get last 3 requests, newest first
                            int count = 0;
                            for (int i = pickupRequests.size() - 1; i >= 0 && count < 3; i--) {
                                PickupRequest p = pickupRequests.get(i);
                                hasActivity = true;
                                count++;
                    %>
                    <div style="padding: 10px 0; border-bottom: 1px solid #dee2e6;">
                        <strong>Pickup <%= p.getStatus() %></strong><br>
                        <span><%= p.getPickupDate() %> - Request #<%= String.format("%04d", p.getRequestId()) %></span>
                    </div>
                    <%
                            }
                        }
                        if (!hasActivity) {
                    %>
                    <p>No recent activity. <a href="requestPickup.jsp">Make your first pickup request!</a></p>
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
        
        // Add some interactivity
        document.addEventListener('DOMContentLoaded', function() {
            // Add hover effects to stat cards
            const statCards = document.querySelectorAll('.stat-card');
            statCards.forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-5px)';
                    this.style.transition = 'transform 0.2s ease';
                });
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                });
            });
            
            // Add click effect to quick action buttons
            const quickActionButtons = document.querySelectorAll('.quick-actions .btn');
            quickActionButtons.forEach(button => {
                button.addEventListener('click', function(e) {
                    // Optional: Add a subtle click effect
                    this.style.transform = 'scale(0.98)';
                    setTimeout(() => {
                        this.style.transform = 'scale(1)';
                    }, 150);
                });
            });
        });
    </script>
</body>
</html>