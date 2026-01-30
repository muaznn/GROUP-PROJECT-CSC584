<%@page import="com.recyclehub.model.PickupDetails"%>
<%@page import="com.recyclehub.model.Collector"%>
<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    // Helper method to calculate points based on weight and material type (Java 5 compatible)
    private int calculatePoints(double weight, String category) {
        double pointsPerKg = 10.0; // Base points per kg
        
        if (category != null) {
            String catLower = category.toLowerCase();
            
            // Use if-else instead of switch for Java 5 compatibility
            if (catLower.contains("plastic")) {
                pointsPerKg = 12.0;
            } else if (catLower.contains("paper") || catLower.contains("cardboard")) {
                pointsPerKg = 6.0;
            } else if (catLower.contains("glass")) {
                pointsPerKg = 8.0;
            } else if (catLower.contains("metal") || catLower.contains("aluminum")) {
                pointsPerKg = 15.0;
            } else if (catLower.contains("e-waste") || catLower.contains("electronic")) {
                pointsPerKg = 20.0;
            } else if (catLower.contains("organic") || catLower.contains("compost")) {
                pointsPerKg = 3.0;
            } else if (catLower.contains("textile") || catLower.contains("fabric") || catLower.contains("cloth")) {
                pointsPerKg = 7.0;
            }
            // else use default 10.0
        }
        
        return (int) Math.round(weight * pointsPerKg);
    }
%>

<%
    // ULTRA-SAFE NULL HANDLING
    PickupRequest p = null;
    List detailsList = null;
    List collectorList = null;
    
    try {
        p = (PickupRequest) request.getAttribute("request");
        detailsList = (List) request.getAttribute("detailsList");
        collectorList = (List) request.getAttribute("collectorList");
    } catch (Exception e) {
        // Ignore, we'll handle nulls
    }
    
    // If request is null, show error
    if (p == null) {
%>
<!DOCTYPE html>
<html>
<head>
    <title>Error - Request Not Found</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 40px; text-align: center; }
        .error { color: #dc3545; margin: 20px 0; }
    </style>
</head>
<body>
    <h1 class="error">Error: Request Not Found</h1>
    <p>The requested pickup request could not be loaded.</p>
    <p><a href="AllRequestsServlet">Back to All Requests</a></p>
</body>
</html>
<%
        return;
    }
    
    // SAFE value extraction with defaults
    int requestId = 0;
    try { requestId = p.getRequestId(); } catch (Exception e) { requestId = 0; }
    
    int userId = 0;
    try { userId = p.getUserId(); } catch (Exception e) { userId = 0; }
    
    String userName = "User";
    try { 
        userName = p.getUserName(); 
        if (userName == null) userName = "User #" + userId;
    } catch (Exception e) { 
        userName = "User #" + userId; 
    }
    
    String collectorName = "Not assigned";
    try { 
        collectorName = p.getCollectorName(); 
        if (collectorName == null || collectorName.trim().isEmpty()) {
            collectorName = "Not assigned";
        }
    } catch (Exception e) { 
        collectorName = "Not assigned"; 
    }
    
    String status = "Pending";
    try { 
        status = p.getStatus(); 
        if (status == null || status.trim().isEmpty()) {
            status = "Pending";
        }
    } catch (Exception e) { 
        status = "Pending"; 
    }
    
    String requestDate = "Unknown date";
    try { 
        requestDate = p.getRequestDate() != null ? p.getRequestDate().toString() : "Unknown date"; 
    } catch (Exception e) { 
        requestDate = "Unknown date"; 
    }
    
    String pickupTime = "Anytime";
    try { 
        pickupTime = p.getPickupTime(); 
        if (pickupTime == null || pickupTime.trim().isEmpty()) {
            pickupTime = "Anytime";
        }
    } catch (Exception e) { 
        pickupTime = "Anytime"; 
    }
    
    int collectorId = 0;
    try { collectorId = p.getCollectorId(); } catch (Exception e) { collectorId = 0; }
    
    String statusClass = status.toLowerCase().replace(" ", "-");
    
    // Calculate total weight and points SAFELY
    double totalWeight = 0.0;
    int totalPoints = 0;
    if (detailsList != null && !detailsList.isEmpty()) {
        for(Object o : detailsList) {
            try {
                PickupDetails d = (PickupDetails) o;
                double itemWeight = 0.0;
                try {
                    itemWeight = d.getWeight();
                } catch (Exception e) {
                    itemWeight = 0.0;
                }
                totalWeight += itemWeight;
                
                String category = "Unknown";
                try {
                    category = d.getCategory();
                } catch (Exception e) {
                    category = "Unknown";
                }
                if (category == null) category = "Unknown";
                
                // Calculate points for this item
                totalPoints += calculatePoints(itemWeight, category);
            } catch (Exception e) {
                // Skip invalid detail
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Request - RecycleHub</title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* Add any custom styles here */
        .null-safe { font-style: italic; color: #666; }
        .admin-action-group { margin-top: 20px; padding-top: 15px; border-top: 1px solid #e0e0e0; }
    </style>
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="AdminDashboardServlet" class="logo">
                <span>♻️</span>
                <span>RecycleHub Admin</span>
            </a>
            <nav>
                <ul>
                    <li><a href="AdminDashboardServlet">Dashboard</a></li>
                    <li><a href="AllRequestsServlet">All Requests</a></li>
                    <li><a href="AdminCollectorServlet">Manage Collectors</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span class="user-role">Admin</span>
                <a href="LogoutServlet" class="btn btn-danger">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">Edit Request: REQ-<%= String.format("%04d", requestId) %></h1>
            
            <div class="card">
                <h3>Request Information</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-top: 20px;">
                    <div>
                        <h4>Pickup Information</h4>
                        <p><strong>Date:</strong> <%= requestDate %></p>
                        <p><strong>Time Slot:</strong> <%= pickupTime %></p>
                        <p><strong>Status:</strong> <span class="status-badge status-<%= statusClass %>"><%= status %></span></p>
                        <p><strong>Assigned Collector:</strong> <%= collectorName %></p>
                        <p><strong>Requested By:</strong> <%= userName %> (ID: <%= userId %>)</p>
                    </div>
                    <div>
                        <h4>Materials</h4>
                        <ul style="list-style: none; padding: 0;">
                            <% 
                            if (detailsList != null && !detailsList.isEmpty()) {
                                for(Object o : detailsList) {
                                    try {
                                        PickupDetails d = (PickupDetails) o;
                                        double itemWeight = 0.0;
                                        try { itemWeight = d.getWeight(); } catch (Exception e) { itemWeight = 0.0; }
                                        String category = "Unknown";
                                        try { category = d.getCategory(); } catch (Exception e) { category = "Unknown"; }
                                        if (category == null) category = "Unknown";
                            %>
                                    <li style="padding: 8px 0; border-bottom: 1px solid var(--gray-medium);">
                                        <strong><%= category %>:</strong> 
                                        <%= String.format("%.1f", itemWeight) %> kg
                                    </li>
                            <% 
                                    } catch (Exception e) {
                                        // Skip invalid detail
                                    }
                                }
                            } else {  
                            %>
                                <li class="null-safe">No materials listed</li>
                            <% } %>
                        </ul>

                        <% if (totalWeight > 0) { %>
                            <div style="margin-top: 15px; padding: 10px; background: var(--lighter-green); border-radius: var(--radius);">
                                <strong>Total Estimated Weight:</strong> <%= String.format("%.1f", totalWeight) %> kg
                                <br><strong>Estimated Points:</strong> <span style="color: var(--dark-green); font-weight: bold;"><%= totalPoints %> pts</span>
                            </div>
                        <% } %>
                    </div>
                </div>
                
                <% if ("Completed".equalsIgnoreCase(status) && totalWeight > 0) { %>
                <div style="margin-top: 20px; padding: 20px; background: linear-gradient(135deg, var(--light-green), var(--primary-green)); color: white; border-radius: var(--radius);">
                    <h4 style="color: white;">Collection Results</h4>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 15px;">
                        <div>
                            <div style="font-size: 14px; opacity: 0.9;">Final Weight</div>
                            <div style="font-size: 28px; font-weight: 700;"><%= String.format("%.1f", totalWeight) %> kg</div>
                        </div>
                        <div>
                            <div style="font-size: 14px; opacity: 0.9;">CO₂ Saved</div>
                            <div style="font-size: 28px; font-weight: 700;"><%= Math.round(totalWeight * 1.33) %> kg</div>
                        </div>
                        <div>
                            <div style="font-size: 14px; opacity: 0.9;">Points Earned</div>
                            <div style="font-size: 28px; font-weight: 700;"><%= totalPoints %></div>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Admin Actions Forms -->
                <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid var(--gray-medium);">
                    <h3>Admin Actions</h3>
                    
                    <!-- Assign Collector Form -->
                    <div class="admin-action-group">
                        <h4>1. Assign Collector</h4>
                        <form action="AdminEditRequestServlet" method="POST" style="display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="action" value="assign">
                            <input type="hidden" name="requestId" value="<%= requestId %>">
                            
                            <div style="flex: 1; min-width: 200px;">
                                <label class="form-label">Select Collector</label>
                                <select name="collectorId" class="form-control" required>
                                    <option value="">Select Collector...</option>
                                    <% 
                                    if (collectorList != null && !collectorList.isEmpty()) {
                                        for(Object obj : collectorList) { 
                                            try {
                                                Collector c = (Collector) obj;
                                                int cId = 0;
                                                try { cId = c.getCollectorId(); } catch (Exception e) { cId = 0; }
                                                String cName = "Collector";
                                                try { cName = c.getName(); } catch (Exception e) { cName = "Collector"; }
                                                if (cName == null) cName = "Collector #" + cId;
                                                boolean isSelected = (collectorId == cId);
                                    %>
                                        <option value="<%= cId %>" <%= isSelected ? "selected" : "" %>>
                                            <%= cName %>
                                        </option>
                                    <% 
                                            } catch (Exception e) {
                                                // Skip invalid collector
                                            }
                                        }
                                    } else { 
                                    %>
                                        <option value="" disabled>No collectors available</option>
                                    <% } %>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary">Assign Collector</button>
                        </form>
                    </div>

                    <!-- Update Status Form -->
                    <div class="admin-action-group">
                        <h4>2. Update Status</h4>
                        <form action="AdminEditRequestServlet" method="POST" style="display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="action" value="status">
                            <input type="hidden" name="requestId" value="<%= requestId %>">
                            
                            <div style="flex: 1; min-width: 200px;">
                                <label class="form-label">Select Status</label>
                                <select name="status" class="form-control">
                                    <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                                    <option value="Scheduled" <%= "Scheduled".equals(status) ? "selected" : "" %>>Scheduled</option>
                                    <option value="In Progress" <%= "In Progress".equals(status) ? "selected" : "" %>>In Progress</option>
                                    <option value="Completed" <%= "Completed".equals(status) ? "selected" : "" %>>Completed</option>
                                    <option value="Cancelled" <%= "Cancelled".equals(status) ? "selected" : "" %>>Cancelled</option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-secondary">Update Status</button>
                        </form>
                    </div>
                    
                    <!-- Complete & Save Form -->
                    <div class="admin-action-group">
                        <h4>3. Record Final Data</h4>
                        <form action="AdminEditRequestServlet" method="POST" style="display: flex; gap: 10px; align-items: flex-end; flex-wrap: wrap;">
                            <input type="hidden" name="action" value="complete">
                            <input type="hidden" name="requestId" value="<%= requestId %>">
                            
                            <div style="flex: 1; min-width: 200px;">
                                <label class="form-label">Final Weight (kg) - After Collection</label>
                                <input type="number" step="0.1" name="weight" class="form-control" 
                                       value="<%= (totalWeight > 0) ? String.format("%.1f", totalWeight) : "" %>"
                                       placeholder="0.0" required>
                            </div>
                            
                            <button type="submit" class="btn btn-primary" style="background-color: var(--dark-green);">
                                Complete & Save
                            </button>
                        </form>
                    </div>
                    
                    <!-- Navigation -->
                    <div style="margin-top: 30px; padding-top: 20px; border-top: 2px solid var(--gray-medium); display: flex; justify-content: space-between;">
                        <a href="AllRequestsServlet" class="btn">Back to List</a>
                        <% if (!"Cancelled".equalsIgnoreCase(status) && !"Completed".equalsIgnoreCase(status)) { %>
                        <form action="AdminEditRequestServlet" method="POST" style="display: inline;">
                            <input type="hidden" name="action" value="cancel">
                            <input type="hidden" name="requestId" value="<%= requestId %>">
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Cancel this request?')">
                                Cancel Request
                            </button>
                        </form>
                        <% } %>
                    </div>
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
                <div class="copyright">
                    &copy; 2023 RecycleHub. All rights reserved.
                </div>
            </div>
        </div>
    </footer>
</body>
</html>