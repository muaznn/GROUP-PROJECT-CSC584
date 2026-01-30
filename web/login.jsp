<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Login</title>
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
                    <li><a href="register.jsp">Register</a></li>
                </ul>
            </nav>
        </div>
    </header>

    <main class="container">
        <div id="login-page" class="page-container active">
            <div class="auth-container">
                <div class="auth-card">
                    <h2 class="auth-title">Welcome Back</h2>
                    <p class="auth-subtitle">Login to manage your recycling pickups</p>
                    
                    <% 
                        if (request.getParameter("registered") != null) {
                    %>
                        <div class="alert alert-success" style="color: green; background: #e6ffe6; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                            Registration successful! Please login.
                        </div>
                    <% } %>
                    
                    <% 
                        String error = (String) request.getAttribute("errorMessage");
                        if (error != null) {
                    %>
                        <div class="alert alert-error" style="display: block; color: red; background: #ffe6e6; padding: 10px; border-radius: 5px; margin-bottom: 15px;">
                            <%= error %>
                        </div>
                    <% } %>

                    <form action="LoginServlet" method="POST">
                        <div class="form-group">
                            <label for="login-email" class="form-label">Email Address</label>
                            <input type="email" id="login-email" name="email" class="form-control" placeholder="e.g., user@recyclehub.com" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="login-password" class="form-label">Password</label>
                            <input type="password" id="login-password" name="password" class="form-control" required>
                        </div>
                        
                        <div style="text-align: right; margin-bottom: 20px;">
                            <a href="#" style="color:var(--primary-color); text-decoration: none; font-size: 14px;">Forgot Password?</a>
                        </div>
                        
                        <button type="submit" class="btn btn-primary btn-block">Login</button>
                    </form>
                    
                    <div class="auth-footer">
                        <p>Don't have an account? <a href="register.jsp">Register here</a></p>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>