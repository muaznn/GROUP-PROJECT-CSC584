<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Register</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="login.jsp" class="logo">
                <span>♻️</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul id="nav-menu">
                    <li><a href="login.jsp">Login</a></li>
                    <li><a href="register.jsp" class="active">Register</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container">
        <div id="register-page" class="page-container active">
            <div class="auth-container">
                <div class="auth-card">
                    <h2 class="auth-title">Create Account</h2>
                    <p class="auth-subtitle">Join the recycling revolution today</p>
                    
                    <% 
                        String error = (String) request.getAttribute("errorMessage");
                        if (error != null) {
                    %>
                        <div class="alert alert-error" style="color: red; background: #ffe6e6; padding: 10px; margin-bottom: 15px; border-radius: 5px;">
                            <%= error %>
                        </div>
                    <% } %>

                    <form action="RegisterServlet" method="POST">
                        <div class="form-group">
                            <label for="reg-name" class="form-label">Full Name</label>
                            <input type="text" id="reg-name" name="name" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="reg-email" class="form-label">Email Address</label>
                            <input type="email" id="reg-email" name="email" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="reg-phone" class="form-label">Phone Number</label>
                            <input type="tel" id="reg-phone" name="phone" class="form-control" required>
                        </div>

                        <div class="form-group">
                            <label for="reg-address" class="form-label">Home Address</label>
                            <textarea id="reg-address" name="address" class="form-control" rows="2" required></textarea>
                        </div>
                        
                        <div class="form-group">
                            <label for="reg-password" class="form-label">Password</label>
                            <input type="password" id="reg-password" name="password" class="form-control" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="reg-confirm" class="form-label">Confirm Password</label>
                            <input type="password" id="reg-confirm" class="form-control" required>
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-block">Register Now</button>
                    </form>
                    <div class="auth-footer">
                        <p>Already have an account? <a href="login.jsp">Login here</a></p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>