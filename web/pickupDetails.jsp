<%@page import="com.recyclehub.model.PickupDetails"%>
<%@page import="com.recyclehub.model.PickupRequest"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Pickup Request Details</title>
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
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            border: 1px solid #dee2e6;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .detail-section h4 {
            color: #2ecc71;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #dee2e6;
            font-size: 18px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .detail-section h4 i {
            color: #2ecc71;
        }
        
        .detail-item {
            margin-bottom: 15px;
            display: flex;
            align-items: flex-start;
        }
        
        .detail-label {
            font-weight: 600;
            color: #495057;
            min-width: 140px;
            font-size: 14px;
        }
        
        .detail-value {
            color: #212529;
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
            border-bottom: 1px solid #dee2e6;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .material-item:last-child {
            border-bottom: none;
        }
        
        .material-name {
            font-weight: 500;
            color: #212529;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .material-weight {
            color: #2ecc71;
            font-weight: 600;
            background: #e8f5e8;
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
            background: linear-gradient(135deg, #e8f5e8, #e0f2f1);
            border-radius: 8px;
        }
        
        .summary-item {
            text-align: center;
        }
        
        .summary-label {
            font-size: 13px;
            color: #495057;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        
        .summary-value {
            font-size: 24px;
            font-weight: 700;
            color: #2ecc71;
        }
        
        .request-header-card {
            background: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 25px;
            border-left: 5px solid #2ecc71;
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
            color: #2ecc71;
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
            border-top: 2px solid #dee2e6;
            text-align: center;
        }
        
        .completed-banner {
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            color: white;
            padding: 25px;
            border-radius: 8px;
            margin-top: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .completed-banner .summary-grid {
            background: rgba(255,255,255,0.15);
            margin-top: 15px;
        }
        
        .completed-banner .summary-value {
            color: white;
        }
        
        .completed-banner .summary-label {
            color: rgba(255,255,255,0.9);
        }
        
        .no-data {
            text-align: center;
            padding: 30px;
            color: #6c757d;
            background: #f8f9fa;
            border-radius: 8px;
            border: 2px dashed #dee2e6;
        }
        
        .no-data i {
            font-size: 40px;
            margin-bottom: 15px;
            color: #adb5bd;
            display: block;
        }
        
        .status-badge {
            padding: 5px 12px;
            border-radius: 15px;
            font-weight: 600;
            font-size: 13px;
            text-transform: uppercase;
            display: inline-block;
        }
        
        .status-pending {
            background-color: #ffc107;
            color: black;
        }
        
        .status-assigned {
            background-color: #17a2b8;
            color: white;
        }
        
        .status-completed {
            background-color: #28a745;
            color: white;
        }
        
        .status-cancelled {
            background-color: #dc3545;
            color: white;
        }
        
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: 500;
            text-decoration: none;
            border: none;
            cursor: pointer;
            gap: 8px;
            font-size: 14px;
            transition: all 0.2s;
        }
        
        .btn-primary {
            background: #2ecc71;
            color: white;
        }
        
        .btn-primary:hover {
            background: #27ae60;
            transform: translateY(-1px);
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
            transform: translateY(-1px);
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-danger:hover {
            background: #c82333;
            transform: translateY(-1px);
        }
        
        .page-title {
            font-size: 28px;
            color: #212529;
            margin-bottom: 30px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .page-title i {
            color: #2ecc71;
        }
    </style>
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
    <%
        // Get user info from session
        HttpSession userSession = request.getSession(false);
        String displayName = "User";
        String userRole = "User";
        
        if (userSession != null) {
            Object nameAttr = userSession.getAttribute("name");
            Object userNameAttr = userSession.getAttribute("username");
            Object userIdAttr = userSession.getAttribute("userId");
            
            if (nameAttr != null) {
                displayName = nameAttr.toString();
            } else if (userNameAttr != null) {
                displayName = userNameAttr.toString();
            } else if (userIdAttr != null) {
                displayName = "User #" + userIdAttr.toString();
            }
            
            Object roleAttr = userSession.getAttribute("role");
            if (roleAttr != null) {
                userRole = roleAttr.toString();
            }
        }
    %>
    <span id="user-display"><%= displayName %></span>
    <span id="user-role" class="user-role"><%= userRole %></span>
    <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
</div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <%
                PickupRequest p = (PickupRequest) request.getAttribute("pickupRequest");
                List<PickupDetails> detailsList = (List<PickupDetails>) request.getAttribute("detailsList");
                Double totalWeight = (Double) request.getAttribute("totalWeight");
                Double totalCO2 = (Double) request.getAttribute("totalCO2");
                Integer totalPoints = (Integer) request.getAttribute("totalPoints");
                
                if (p == null) {
                    response.sendRedirect("DashboardServlet");
                    return;
                }
                
                String statusClass = p.getStatus() != null ? 
                    p.getStatus().toLowerCase().replace(" ", "-") : "default";
            %>
            
            <h1 class="page-title">
                <i class="fas fa-file-alt"></i>
                Pickup Request Details
            </h1>
            
            <!-- Request Header Card -->
            <div class="request-header-card">
                <div class="request-title-row">
                    <div class="request-id">REQ-<%= String.format("%04d", p.getRequestId()) %></div>
                    <span class="status-badge status-<%= statusClass %> status-large"><%= p.getStatus() %></span>
                </div>
                <div style="color: #6c757d; font-size: 14px; display: flex; align-items: center; gap: 10px;">
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
                        <span class="detail-label">Request Date:</span>
                        <span class="detail-value"><%= p.getRequestDate() %></span>
                    </div>
                    
                    <div class="detail-item">
                        <span class="detail-label">Pickup Date:</span>
                        <span class="detail-value"><%= p.getPickupDate() != null ? p.getPickupDate() : "Not scheduled" %></span>
                    </div>
                    
                    <div class="detail-item">
                        <span class="detail-label">Time Slot:</span>
                        <span class="detail-value">
                            <% if (p.getPickupTime() != null && !p.getPickupTime().isEmpty()) { %>
                                <span class="status-badge" style="background: #17a2b8; color: white; font-size: 12px;">
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
                            <i class="fas fa-user-circle" style="color: #17a2b8; margin-right: 8px;"></i>
                            <%= p.getCollectorName() %>
                        </span>
                    </div>
                    <% } %>
                    
                    
                </div>

                <!-- Materials Section -->
                <div class="detail-section">
                    <h4><i class="fas fa-recycle"></i> Materials Collection</h4>
                    
                    <% 
                    double calculatedWeight = 0.0;
                    int calculatedPoints = 0;
                    if (detailsList != null && !detailsList.isEmpty()) {
                    %>
                        <ul class="materials-list">
                            <% for(PickupDetails d : detailsList) {
                                double itemWeight = d.getWeight();
                                calculatedWeight += itemWeight;
                                
                                // Calculate points (simplified version)
                                double pointsPerKg = 10.0;
                                if (d.getCategory().toLowerCase().contains("plastic")) {
                                    pointsPerKg = 12.0;
                                } else if (d.getCategory().toLowerCase().contains("paper") || d.getCategory().toLowerCase().contains("cardboard")) {
                                    pointsPerKg = 6.0;
                                } else if (d.getCategory().toLowerCase().contains("glass")) {
                                    pointsPerKg = 8.0;
                                } else if (d.getCategory().toLowerCase().contains("metal")) {
                                    pointsPerKg = 15.0;
                                }
                                calculatedPoints += (int) Math.round(itemWeight * pointsPerKg);
                                
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
                                }
                            %>
                                <li class="material-item">
                                    <span class="material-name">
                                        <i class="<%= iconClass %>" style="color: #2ecc71;"></i>
                                        <%= d.getCategory() %>
                                    </span>
                                    <span class="material-weight"><%= String.format("%.1f", itemWeight) %> kg</span>
                                </li>
                            <% } %>
                        </ul>
                        
                        <!-- Use calculated or provided totals -->
                        <% 
                            double displayWeight = totalWeight != null ? totalWeight : calculatedWeight;
                            int displayPoints = totalPoints != null ? totalPoints : calculatedPoints;
                        %>
                        
                        <!-- Summary Section -->
                        <div class="summary-grid">
                            <div class="summary-item">
                                <div class="summary-label">Total Weight</div>
                                <div class="summary-value"><%= String.format("%.1f", displayWeight) %> kg</div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">Estimated Points</div>
                                <div class="summary-value"><%= displayPoints %></div>
                            </div>
                            <div class="summary-item">
                                <div class="summary-label">CO₂ Saved</div>
                                <div class="summary-value"><%= Math.round(displayWeight * 1.33) %> kg</div>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="no-data">
                            <i class="fas fa-inbox"></i>
                            <p>No specific materials listed for this request.</p>
                        </div>
                        
                        <% if (totalWeight != null && totalWeight > 0) { %>
                        <div class="summary-grid">
                            <div class="summary-item">
                                <div class="summary-label">Total Weight</div>
                                <div class="summary-value"><%= String.format("%.1f", totalWeight) %> kg</div>
                            </div>
                            <% if (totalPoints != null) { %>
                            <div class="summary-item">
                                <div class="summary-label">Total Points</div>
                                <div class="summary-value"><%= totalPoints %></div>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>

            <!-- Completed Request Banner (if applicable) -->
            <% if ("Completed".equalsIgnoreCase(p.getStatus()) && (totalWeight != null || calculatedWeight > 0)) { 
                double completedWeight = totalWeight != null ? totalWeight : calculatedWeight;
            %>
                <div class="completed-banner">
                    <h4 style="color: white; margin-top: 0; display: flex; align-items: center; gap: 10px;">
                        <i class="fas fa-check-circle"></i>
                        Collection Successfully Completed
                    </h4>
                    <p style="color: rgba(255,255,255,0.9); margin-bottom: 15px; font-size: 14px;">
                        This request has been completed and points have been awarded to your account.
                    </p>
                    <div class="summary-grid">
                        <div class="summary-item">
                            <div class="summary-label">Final Weight</div>
                            <div class="summary-value"><%= String.format("%.1f", completedWeight) %> kg</div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">CO₂ Saved</div>
                            <div class="summary-value"><%= Math.round(completedWeight * 1.33) %> kg</div>
                        </div>
                        <div class="summary-item">
                            <div class="summary-label">Points Awarded</div>
                            <div class="summary-value">
                                <% if (totalPoints != null) { %>
                                    <%= totalPoints %>
                                <% } else if (calculatedPoints > 0) { %>
                                    <%= calculatedPoints %>
                                <% } else { %>
                                    <%= (int) Math.round(completedWeight * 10) %>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            <% } %>

            <!-- Back Button & Actions -->
            <div class="back-action">
                <a href="DashboardServlet" class="btn btn-secondary">
                    <i class="fas fa-arrow-left" style="margin-right: 8px;"></i>
                    Back to Dashboard
                </a>
                
                <% if ("Pending".equalsIgnoreCase(p.getStatus())) { %>
                <form action="PickupDetailsServlet" method="POST" style="display: inline; margin-left: 10px;">
                    <input type="hidden" name="action" value="cancel">
                    <input type="hidden" name="requestId" value="<%= p.getRequestId() %>">
                    <button type="submit" class="btn btn-danger" 
                            onclick="return confirm('Are you sure you want to cancel this pickup request?')">
                        <i class="fas fa-times" style="margin-right: 8px;"></i>
                        Cancel Request
                    </button>
                </form>
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
        document.addEventListener('DOMContentLoaded', function() {
            // Logout confirmation
            const logoutBtn = document.querySelector('a[href="LogoutServlet"]');
            if (logoutBtn) {
                logoutBtn.addEventListener('click', function(e) {
                    if (!confirm('Are you sure you want to logout?')) {
                        e.preventDefault();
                    }
                });
            }
            
            // Button hover effects
            const buttons = document.querySelectorAll('.btn');
            buttons.forEach(btn => {
                btn.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 8px rgba(0,0,0,0.1)';
                });
                
                btn.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = 'none';
                });
            });
        });
    </script>
</body>
</html>