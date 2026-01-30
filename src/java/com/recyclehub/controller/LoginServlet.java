package com.recyclehub.controller;

import com.recyclehub.dao.UserDAO;
import com.recyclehub.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get data from the JSP form
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // 2. Ask the DAO to check the database
        UserDAO dao = new UserDAO();
        User user = dao.loginUser(email, password);
        
        if (user != null) {
            // SUCCESS: Login worked!
            
            // Create a Session (The browser remembers who you are)
            HttpSession session = request.getSession();
            session.setAttribute("user", user); // Save the whole User object
            
            // Check Role and Redirect
            if ("admin".equals(user.getRole())) {
                response.sendRedirect("AdminDashboardServlet");
            } else {
                response.sendRedirect("DashboardServlet");
            }
            
        } else {
            // FAILURE: Login failed.
            
            // Send an error message back to login.jsp
            request.setAttribute("errorMessage", "Invalid email or password. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}