<%@page import="com.recyclehub.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get user data from session or database
    String userRole = user.getRole() != null ? user.getRole() : "User";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - My Profile</title>
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
                    <li><a href="profile.jsp" class="active">Profile</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= user.getName() != null ? user.getName() : "User" %></span>
                <span id="user-role" class="user-role"><%= userRole %></span>
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">My Profile</h1>
            
            <div class="card">
                <form id="profile-form" action="ProfileServlet" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                    
                    <div class="form-group">
                        <label for="profile-name" class="form-label">Full Name</label>
                        <input type="text" id="profile-name" name="name" class="form-control" 
                               value="<%= user.getName() != null ? user.getName() : "" %>" required>
                    </div>
                    <div class="form-group">
                        <label for="profile-email" class="form-label">Email Address</label>
                        <input type="email" id="profile-email" class="form-control" 
                               value="<%= user.getEmail() != null ? user.getEmail() : "" %>" readonly>
                    </div>
                    <div class="form-group">
                        <label for="profile-phone" class="form-label">Phone Number</label>
                        <input type="tel" id="profile-phone" name="phone" class="form-control" 
                               value="<%= user.getPhone() != null ? user.getPhone() : "" %>">
                    </div>
                    <div class="form-group">
                        <label for="profile-address" class="form-label">Address</label>
                        <textarea id="profile-address" name="address" class="form-control" rows="3"><%= user.getAddress() != null ? user.getAddress() : "" %></textarea>
                    </div>
                    
                    <h3 style="margin-top: 30px; margin-bottom: 20px; color: #28a745;">Change Password</h3>
                    <div class="form-group">
                        <label for="current-password" class="form-label">Current Password</label>
                        <input type="password" id="current-password" name="currentPassword" class="form-control" placeholder="Enter current password">
                    </div>
                    <div class="form-group">
                        <label for="new-password" class="form-label">New Password</label>
                        <input type="password" id="new-password" name="newPassword" class="form-control" placeholder="Enter new password">
                    </div>
                    <div class="form-group">
                        <label for="confirm-password" class="form-label">Confirm New Password</label>
                        <input type="password" id="confirm-password" name="confirmPassword" class="form-control" placeholder="Confirm new password">
                    </div>
                    
                    <div id="form-message" class="alert" style="display: none; margin: 15px 0;"></div>
                    
                    <div style="display: flex; gap: 15px; margin-top: 25px;">
                        <button type="submit" class="btn btn-primary">Update Profile</button>
                        <a href="DashboardServlet" class="btn">Cancel</a>
                    </div>
                </form>
            </div>
            
            <!-- Display user stats if available -->
            <% if (user.getCurrentPoints() > 0) { %>
            <div class="card" style="margin-top: 30px;">
                <h3 style="color: #28a745; margin-bottom: 15px;">Your Eco Stats</h3>
                <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                    <div style="text-align: center; padding: 15px; background: #e8f5e8; border-radius: 8px;">
                        <div style="font-size: 24px; font-weight: 700; color: #28a745;"><%= user.getCurrentPoints() %></div>
                        <div style="font-size: 14px; color: #666;">Eco Points</div>
                    </div>
                    
                </div>
            </div>
            <% } %>
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
        
        // Form validation
        document.getElementById('profile-form').addEventListener('submit', function(e) {
            const currentPassword = document.getElementById('current-password').value;
            const newPassword = document.getElementById('new-password').value;
            const confirmPassword = document.getElementById('confirm-password').value;
            const messageDiv = document.getElementById('form-message');
            
            // Clear previous messages
            messageDiv.style.display = 'none';
            messageDiv.className = 'alert';
            
            // Password change validation
            if (newPassword || confirmPassword) {
                if (!currentPassword) {
                    e.preventDefault();
                    showMessage('Please enter your current password to change password', 'error');
                    return false;
                }
                
                if (newPassword !== confirmPassword) {
                    e.preventDefault();
                    showMessage('New passwords do not match', 'error');
                    return false;
                }
                
                if (newPassword.length < 6) {
                    e.preventDefault();
                    showMessage('New password must be at least 6 characters long', 'error');
                    return false;
                }
            }
            
            // Show loading state
            const submitBtn = this.querySelector('button[type="submit"]');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = 'Updating...';
            submitBtn.disabled = true;
            
            // Allow form submission
            return true;
        });
        
        function showMessage(message, type) {
            const messageDiv = document.getElementById('form-message');
            messageDiv.textContent = message;
            messageDiv.className = 'alert alert-' + (type === 'error' ? 'error' : 'success');
            messageDiv.style.display = 'block';
            
            // Scroll to message
            messageDiv.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }
        
        // Handle success/error messages from servlet
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const updated = urlParams.get('updated');
            const message = urlParams.get('message');
            
            if (updated === 'success') {
                showMessage('Profile updated successfully!', 'success');
                // Clear URL parameters
                window.history.replaceState({}, document.title, window.location.pathname);
            } else if (updated === 'error') {
                showMessage(message || 'Failed to update profile. Please try again.', 'error');
                window.history.replaceState({}, document.title, window.location.pathname);
            }
            
            // Add input validation
            const phoneInput = document.getElementById('profile-phone');
            if (phoneInput) {
                phoneInput.addEventListener('input', function() {
                    // Allow only numbers, spaces, and hyphens
                    this.value = this.value.replace(/[^\d\s\-]/g, '');
                });
            }
            
            // Add character counter for address
            const addressTextarea = document.getElementById('profile-address');
            if (addressTextarea) {
                addressTextarea.addEventListener('input', function() {
                    const charCount = this.value.length;
                    const maxLength = 200;
                    
                    // Show warning if接近 limit
                    if (charCount > maxLength - 20) {
                        this.style.borderColor = '#ff9800';
                    } else {
                        this.style.borderColor = '';
                    }
                });
            }
        });
        
        // Add hover effects to form inputs
        document.addEventListener('DOMContentLoaded', function() {
            const formInputs = document.querySelectorAll('.form-control');
            formInputs.forEach(input => {
                input.addEventListener('focus', function() {
                    this.style.borderColor = '#28a745';
                    this.style.boxShadow = '0 0 0 2px rgba(40, 167, 69, 0.2)';
                });
                input.addEventListener('blur', function() {
                    this.style.borderColor = '';
                    this.style.boxShadow = '';
                });
            });
            
            // Add animation to submit button
            const submitBtn = document.querySelector('button[type="submit"]');
            if (submitBtn) {
                submitBtn.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-2px)';
                    this.style.boxShadow = '0 4px 8px rgba(0,0,0,0.1)';
                });
                submitBtn.addEventListener('mouseleave', function() {
                    this.style.transform = '';
                    this.style.boxShadow = '';
                });
            }
        });
    </script>
</body>
</html>