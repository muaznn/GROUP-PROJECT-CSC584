<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Schedule Pickup</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .material-icon {
            display: inline-block;
            width: 24px;
            text-align: center;
            font-weight: bold;
        }
        .recycle-icon {
            font-size: 1.2em;
            color: #2ecc71;
        }
    </style>
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="DashboardServlet" class="logo">
                <span class="recycle-icon">&#x267B;</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul>
                    <li><a href="DashboardServlet">Dashboard</a></li>
                    <li><a href="requestPickup.jsp" class="active">Request Pickup</a></li>
                    <li><a href="PickupHistoryServlet">History</a></li>
                    <li><a href="rewards.jsp">Rewards</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display">user</span>
                <span id="user-role" class="user-role">User</span>
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">Schedule New Pickup</h1>
            
            <!-- Display error/success messages -->
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="alert alert-danger">
                    <%= request.getAttribute("errorMessage") %>
                </div>
            <% } %>
            <% if (request.getAttribute("successMessage") != null) { %>
                <div class="alert alert-success">
                    <%= request.getAttribute("successMessage") %>
                </div>
            <% } %>
            
            <div class="card">
                <form action="RequestServlet" method="POST" id="pickup-request-form">
                    <input type="hidden" name="action" value="create">
                    
                    <div class="form-group">
                        <label class="form-label">Pickup Date & Time</label>
                        <div class="datetime-row">
                            <input type="date" 
                                   name="pickupDate" 
                                   id="pickup-date" 
                                   class="form-control date-input" 
                                   min="2026-01-23" 
                                   required>
                            <select name="pickupTime" id="pickup-time" class="form-control time-select" required>
                                <option value="">Select time slot</option>
                                <option value="Morning">Morning (8 AM - 12 PM)</option>
                                <option value="Afternoon">Afternoon (12 PM - 4 PM)</option>
                                <option value="Evening">Evening (4 PM - 7 PM)</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Enter Material Weights (in kg)</label>
                        <div class="material-grid">
                            <div class="material-input-group">
                                <label>
                                    <span class="material-icon" style="color: #3498db;">&#x1F4C4;</span>
                                    Paper & Cardboard (kg)
                                </label>
                                <input type="number" 
                                       step="0.1" 
                                       name="weight_paper" 
                                       class="form-control material-input" 
                                       placeholder="0.0" 
                                       min="0" 
                                       max="1000"
                                       oninput="validateWeight(this)">
                            </div>
                            
                            <div class="material-input-group">
                                <label>
                                    <span class="material-icon" style="color: #e74c3c;">P</span>
                                    Plastics (kg)
                                </label>
                                <input type="number" 
                                       step="0.1" 
                                       name="weight_plastic" 
                                       class="form-control material-input" 
                                       placeholder="0.0" 
                                       min="0" 
                                       max="1000"
                                       oninput="validateWeight(this)">
                            </div>
                            
                            <div class="material-input-group">
                                <label>
                                    <span class="material-icon" style="color: #f39c12;">M</span>
                                    Metals (kg)
                                </label>
                                <input type="number" 
                                       step="0.1" 
                                       name="weight_metal" 
                                       class="form-control material-input" 
                                       placeholder="0.0" 
                                       min="0" 
                                       max="1000"
                                       oninput="validateWeight(this)">
                            </div>
                            
                            <div class="material-input-group">
                                <label>
                                    <span class="material-icon" style="color: #2ecc71;">G</span>
                                    Glass (kg)
                                </label>
                                <input type="number" 
                                       step="0.1" 
                                       name="weight_glass" 
                                       class="form-control material-input" 
                                       placeholder="0.0" 
                                       min="0" 
                                       max="1000"
                                       oninput="validateWeight(this)">
                            </div>
                            
                            <div class="material-input-group">
                                <label>
                                    <span class="material-icon" style="color: #9b59b6;">&#x26A1;</span>
                                    Electronics (kg)
                                </label>
                                <input type="number" 
                                       step="0.1" 
                                       name="weight_electronics" 
                                       class="form-control material-input" 
                                       placeholder="0.0" 
                                       min="0" 
                                       max="1000"
                                       oninput="validateWeight(this)">
                            </div>
                        </div>
                        <p class="help-text">
                            Enter 0.0 if you don't have this material. Minimum weight: 0.5 kg per material for pickup.
                        </p>
                    </div>

                    <div class="form-group">
                        <label for="specialNotes" class="form-label">Special Instructions (Optional)</label>
                        <textarea id="specialNotes" name="specialNotes" class="form-control" rows="3" placeholder="Any special instructions for the collection team..."></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Submit Request</button>
                        <a href="RequestServlet" class="btn btn-secondary">Cancel</a>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="logo">
                    <span class="recycle-icon">&#x267B;</span>
                    <span>RecycleHub</span>
                </div>
                <div class="footer-info">
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
        function validateWeight(input) {
            if (input.value < 0) {
                input.value = 0;
            }
            if (input.value > 1000) {
                input.value = 1000;
            }
            
            // Round to 1 decimal place
            if (input.value && input.value.includes('.')) {
                const parts = input.value.split('.');
                if (parts[1].length > 1) {
                    input.value = parseFloat(input.value).toFixed(1);
                }
            }
        }

        // Form validation before submission
        document.getElementById('pickup-request-form').addEventListener('submit', function(e) {
            // Get all weight inputs
            const weightInputs = document.querySelectorAll('.material-input');
            let totalWeight = 0;
            let hasValidWeights = false;
            const warnings = [];
            
            weightInputs.forEach(input => {
                const weight = parseFloat(input.value) || 0;
                const materialName = input.name.replace('weight_', '').replace('_', ' ');
                totalWeight += weight;
                
                if (weight >= 0.5) {
                    hasValidWeights = true;
                }
                
                // If weight is between 0 and 0.5, add warning
                if (weight > 0 && weight < 0.5) {
                    warnings.push(`${materialName}: Minimum weight for pickup is 0.5 kg. This material may not be collected.`);
                }
            });

            // Show warnings if any
            if (warnings.length > 0) {
                if (!confirm(warnings.join('\n') + '\n\nDo you want to continue?')) {
                    e.preventDefault();
                    return false;
                }
            }

            // Check if at least one material has minimum weight
            if (!hasValidWeights) {
                e.preventDefault();
                alert('Please enter at least one material with minimum 0.5 kg weight for pickup');
                return false;
            }

            // Check if total weight is reasonable
            if (totalWeight > 1000) {
                e.preventDefault();
                alert('Total weight exceeds maximum limit of 1000 kg. Please adjust your inputs.');
                return false;
            }

            return true;
        });

        // Set minimum date to today
        document.addEventListener('DOMContentLoaded', function() {
            // Date validation - can't select past dates
            const dateInput = document.getElementById('pickup-date');
            
            // Format today's date as YYYY-MM-DD
            const today = new Date();
            const yyyy = today.getFullYear();
            const mm = String(today.getMonth() + 1).padStart(2, '0');
            const dd = String(today.getDate()).padStart(2, '0');
            const todayStr = `${yyyy}-${mm}-${dd}`;
            
            dateInput.min = todayStr;
            dateInput.value = todayStr;
            
            dateInput.addEventListener('change', function() {
                const selectedDate = new Date(this.value);
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                
                if (selectedDate < today) {
                    alert('Please select a future date');
                    this.value = todayStr;
                }
            });
            
            // Add focus effects to weight inputs
            const weightInputs = document.querySelectorAll('.material-input');
            weightInputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.parentElement.classList.add('focused');
                });
                input.addEventListener('blur', function() {
                    this.parentElement.classList.remove('focused');
                });
            });
        });
    </script>
</body>
</html>