<%@page import="com.recyclehub.model.PickupDetails"%>
<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    // Helper method to calculate points based on weight and material type
    private int calculatePoints(double weight, String category) {
        double pointsPerKg = 10.0; // Base points per kg
        
        if (category != null) {
            String catLower = category.toLowerCase();
            
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
        }
        
        return (int) Math.round(weight * pointsPerKg);
    }
%>

<%
    // 1. GET DATA
    PickupRequest p = (PickupRequest) request.getAttribute("request");
    List detailsList = (List) request.getAttribute("detailsList");

    // Safety check if direct access without ID
    if (p == null) {
        response.sendRedirect("AllRequestsServlet");
        return;
    }
    
    String statusClass = (p.getStatus() != null) ? p.getStatus().toLowerCase().replace(" ", "-") : "default";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Request - RecycleHub</title>
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .view-details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-top: 25px;
        }
        
        .detail-section {
            background: var(--white);
            padding: 25px;
            border-radius: var(--radius);
            border: 1px solid var(--gray-medium);
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .detail-section h4 {
            color: var(--primary-green);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--gray-medium);
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .detail-section h4 i {
            color: var(--primary-green);
        }
        
        .detail-item {
            margin-bottom: 15px;
            display: flex;
            align-items: flex-start;
        }
        
        .detail-label {
            font-weight: 600;
            color: var(--gray-dark);
            min-width: 140px;
            font-size: 14px;
        }
        
        .detail-value {
            color: var(--text-dark);
            flex: 1;
            font-size: 15px;
        }
        
        .materials-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        
        .material-item {
            padding: 12px 0;
            border-bottom: 1px solid var(--gray-medium);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .material-item:last-child {
            border-bottom: none;
        }
        
        .material-name {
            font-weight: 500;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .material-weight {
            color: var(--primary-green);
            font-weight: 600;
            background: var(--lighter-green);
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 14px;
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 15px;
            margin-top: 20px;
            padding: 20px;
            background: linear-gradient(135deg, var(--lighter-green), #e0f2f1);
            border-radius: var(--radius);
        }
        
        .summary-item {
            text-align: center;
        }
        
        .summary-label {
            font-size: 13px;
            color: var(--gray-dark);
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .summary-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-green);
        }
        
        .request-header-card {
            background: var(--white);
            padding: 25px;
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            margin-bottom: 25px;
            border-left: 5px solid var(--primary-green);
        }
        
        .request-title-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            flex-wrap: wrap;
            gap: 15px;
        }
        
        .request-id {
            font-size: 24px;
            font-weight: 700;
            color: var(--primary-green);
        }
        
        .status-large {
            padding: 8px 20px;
            border-radius: 20px;
            font-weight: 600;
            font-size: 14px;
            text-transform: uppercase;
        }
        
        .back-action {
            margin-top: 30px;
            padding-top: 25px;
            border-top: 2px solid var(--gray-medium);
            text-align: center;
        }
        
        .completed-banner {
            background: linear-gradient(135deg, var(--primary-green), var(--dark-green));
            color: var(--white);
            padding: 25px;
            border-radius: var(--radius);
            margin-top: 30px;
            box-shadow: var(--shadow);
        }
        
        .completed-banner .summary-grid {
            background: rgba(255,255,255,0.15);
            margin-top: 15px;
        }
        
        .completed-banner .summary-value {
            color: var(--white);
        }
        
        .completed-banner .summary-label {
            color: rgba(255,255,255,0.9);
        }
        
        .material-icon {
            width: 30px;
            height: 30px;
            background: var(--light-green);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        
        .no-data {
            text-align: center;
            padding: 30px;
            color: var(--gray-dark);
            background: var(--gray-light);
            border-radius: var(--radius);
            border: 2px dashed var(--gray-medium);
        }
        
        .no-data i {
            font-size: 40px;
            margin-bottom: 15px;
            color: var(--gray-medium);
            display: block;
        }
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
                <a href="LogoutServlet" class="btn btn-danger" style="padding: 5px 15px; font-size: 14px;">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">
                <i class="fas fa-file-alt"></i>
                Request Details
            </h1>
            
            <!-- Request Header Card -->
            <div class="request-header-card">
                <div class="request-title-row">
                    <div class="request-id">REQ-<%= String.format("%04d", p.getRequestId()) %></div>
                    <span class="status-badge status-<%= statusClass %> status-large"><%= p.getStatus() %></span>
                </div>
                <div style="color: var(--gray-dark); font-size: 14px; display: flex; align-items: center; gap: 10px;">
                    <i class="far fa-calendar"></i>
                    Created on: <%= p.getRequestDate() %>
                </div>
            </div>

            <!-- Details Grid -->
            <div class="view-details-grid">
                <!-- Pickup Information Section -->
                <div class="detail-section">
                    <h4><i class="fas fa-calendar-day"></i> Pickup Information</h4>
                    
                    <div class="detail-item">
                        <span class="detail-label">Pickup Date:</span>
                        <span class="detail-value"><%= p.getRequestDate() %></span>
                    </div>
                    
                    <div class="detail-item">
                        <span class="detail-label">Time Slot:</span>
                        <span class="detail-value">
                            <% if (p.getPickupTime() != null && !p.getPickupTime().isEmpty()) { %>
                                <span class="status-badge" style="background: var(--info-blue); color: white; font-size: 12px;">
                                    <%= p.getPickupTime() %>
                                </span>
                            <% } else { %>
                                Flexible
                            <% } %>
                        </span>
                    </div>
                    
                    <div class="detail-item">
                        <span class="detail-label">Status:</span>
                        <span class="detail-value">
                            <span class="status-badge status-<%= statusClass %>" style="font-size: 13px;">
                                <%= p.getStatus() %>
                            </span>
                        </span>
                    </div>
                    
                    <% if (p.getCollectorName() != null && !p.getCollectorName().isEmpty()) { %>
                    <div class="detail-item">
                        <span class="detail-label">Collector:</span>
                        <span class="detail-value">
                            <i class="fas fa-user-circle" style="color: var(--info-blue); margin-right: 8px;"></i>
                            <%= p.getCollectorName() %>
                        </span>
                    </div>
                    <% } %>
                    
                    <div class="detail-item">
                        <span class="detail-label">Requested By:</span>
                        <span class="detail-value">
                            <i class="fas fa-user" style="color: var(--primary-green); margin-right: 8px;"></i>
                            <%= p.getUserName() %> 
                        </span>
                    </div>
                </div>

                <!-- Materials Section -->
                <div class="detail-section">
                    <h4><i class="fas fa-recycle"></i> Materials Collection</h4>
                    
                    <% 
                    double totalWeight = 0.0;
                    int totalPoints = 0;
                    if (detailsList != null && !detailsList.isEmpty()) {
                    %>
                        <ul class="materials-list">
                            <% for(Object o : detailsList) {
                                PickupDetails d = (PickupDetails) o;
                                double itemWeight = d.getWeight();
                                totalWeight += itemWeight;
                                totalPoints += calculatePoints(itemWeight, d.getCategory());
                                
                                // Determine icon based on category
                                String iconClass = "fas fa-recycle";
                                if (d.getCategory().toLowerCase().contains("plastic")) {
                                    iconClass = "fas fa-wine-bottle";
                                } else if (d.getCategory().toLowerCase().contains("paper")) {
                                    iconClass = "fas fa-newspaper";
                                } else if (d.getCategory().toLowerCase().contains("glass")) {
                                    iconClass = "fas fa-glass-martini";
                                } else if (d.getCategory().toLowerCase().contains("metal")) {
                                    iconClass = "fas fa-weight";
                                } else if (d.getCategory().toLowerCase().contains("e-waste")) {
                                    iconClass = "fas fa-laptop";
                                } else if (d.getCategory().toLowerCase().contains("organic")) {
                                    iconClass = "fas fa-leaf";
                                }
                            %>
                                <li class="material-item">
                                    <span class="material-name">
                                        <i class="<%= iconClass %>" style="color: var(--primary-green);"></i>
                                        <%= d.getCategory() %>
                                    </span>
                                    <span class="material-weight"><%= String.format("%.1f", itemWeight) %> kg</span>
                                </li>
                            <% } %>
                        </ul>
                        
                        <!-- Summary Section -->
                        <div class="summary-grid">
                            <div class="summary-item">
                                <div class="summary-label">Total Weight</div>
                                <div class="summary-value"><%= String.format("%.1f", totalWeight) %> kg</div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">Estimated Points</div>
                                <div class="summary-value"><%= totalPoints %></div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">CO₂ Saved</div>
                                <div class="summary-value"><%= Math.round(totalWeight * 1.33) %> kg</div>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="no-data">
                            <i class="fas fa-inbox"></i>
                            <p>No specific materials listed for this request.</p>
                        </div>
                    <% } %>
                </div>
            </div>

            <!-- Completed Request Banner (if applicable) -->
            <% if ("Completed".equalsIgnoreCase(p.getStatus()) && totalWeight > 0) { %>
                <div class="completed-banner">
                    <h4 style="color: white; margin-top: 0; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-check-circle"></i>
                        Collection Successfully Completed
                    </h4>
                    <p style="color: rgba(255,255,255,0.9); margin-bottom: 15px; font-size: 14px;">
                        This request has been completed and points have been awarded to the user.
                    </p>
                    <div class="summary-grid">
                        <div class="summary-item">
                            <div class="summary-label">Final Weight</div>
                            <div class="summary-value"><%= String.format("%.1f", totalWeight) %> kg</div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">CO₂ Saved</div>
                            <div class="summary-value"><%= Math.round(totalWeight * 1.33) %> kg</div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">Points Awarded</div>
                            <div class="summary-value"><%= totalPoints %></div>
                        </div>
                    </div>
                </div>
            <% } %>

            <!-- Back Button -->
            <div class="back-action">
                <button onclick="window.history.back()" class="btn btn-secondary">
                    <i class="fas fa-arrow-left" style="margin-right: 8px;"></i>
                    Back
                </button>
                
                <% if (!"Completed".equalsIgnoreCase(p.getStatus()) && !"Cancelled".equalsIgnoreCase(p.getStatus())) { %>
                <a href="AdminEditRequestServlet?id=<%= p.getRequestId() %>" class="btn btn-primary" style="margin-left: 10px;">
                    <i class="fas fa-edit" style="margin-right: 8px;"></i>
                    Edit / Assign
                </a>
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
        // Simple logout confirmation
        document.addEventListener('DOMContentLoaded', function() {
            const logoutBtn = document.querySelector('a[href="LogoutServlet"]');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', function(e) {
                    if (!confirm('Are you sure you want to logout?')) {
                        e.preventDefault();
                    }
                });
            }
        });
    </script>
</body>
</html>