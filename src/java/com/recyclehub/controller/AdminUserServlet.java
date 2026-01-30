package com.recyclehub.controller;

import com.recyclehub.dao.UserDAO;
import com.recyclehub.model.User;
import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminUserServlet", urlPatterns = {"/AdminUserServlet"})
public class AdminUserServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== DEBUG: AdminUserServlet.doGet() START ===");
        
        // Security Check - Only admin can access
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
            System.out.println("DEBUG: User not authenticated or not admin");
            response.sendRedirect("../login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("DEBUG: Action parameter = " + action);
        
        UserDAO userDAO = new UserDAO();
        
        try {
            if ("view".equals(action)) {
                // View single user
                viewUser(request, response, userDAO);
            } else if ("edit".equals(action)) {
                // Edit user form
                editUserForm(request, response, userDAO);
            } else if ("add".equals(action)) {
                // Add user form
                addUserForm(request, response);
            } else {
                // Default: List all users
                listUsers(request, response, userDAO);
            }
            
        } catch (Exception e) {
            System.err.println("ERROR in AdminUserServlet.doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading users: " + e.getMessage());
            listUsers(request, response, userDAO);
        }
        
        System.out.println("=== DEBUG: AdminUserServlet.doGet() END ===");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== DEBUG: AdminUserServlet.doPost() START ===");
        
        // Security Check
        HttpSession session = request.getSession();
        User loggedInUser = (User) session.getAttribute("user");
        if (loggedInUser == null || !"admin".equalsIgnoreCase(loggedInUser.getRole())) {
            response.sendRedirect("../login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("DEBUG: POST Action = " + action);
        
        UserDAO userDAO = new UserDAO();
        
        try {
            if ("add".equals(action)) {
                // Add new user
                addUser(request, response, userDAO, session);
            } else if ("update".equals(action)) {
                // Update existing user
                updateUser(request, response, userDAO, session);
            } else if ("delete".equals(action)) {
                // Delete user
                deleteUser(request, response, userDAO, session);
            } else {
                // Default: redirect to list
                response.sendRedirect("AdminUserServlet");
            }
            
        } catch (Exception e) {
            System.err.println("ERROR in AdminUserServlet.doPost: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error processing request: " + e.getMessage());
            response.sendRedirect("AdminUserServlet");
        }
        
        System.out.println("=== DEBUG: AdminUserServlet.doPost() END ===");
    }
    
    // ========== GET METHODS ==========
    
    private void listUsers(HttpServletRequest request, HttpServletResponse response, 
                          UserDAO userDAO) throws ServletException, IOException {
    
        System.out.println("DEBUG: Listing all users");
        List<User> users = userDAO.getAllUsers();

        if (users == null) {
            users = new ArrayList<User>();
        }

        // Set deletable status for each user
        for (User user : users) {
            boolean isDeletable = userDAO.isUserDeletable(user.getUserId());
            // We'll add a setDeletable method to User model
            // For now, we'll store it in request attribute
            request.setAttribute("userDeletable_" + user.getUserId(), isDeletable);
            System.out.println("DEBUG: User ID " + user.getUserId() + 
                             " deletable: " + isDeletable);
        }

        request.setAttribute("users", users);
        request.getRequestDispatcher("users.jsp").forward(request, response);
    }
    
    private void viewUser(HttpServletRequest request, HttpServletResponse response,
                         UserDAO userDAO) throws ServletException, IOException {

        String idStr = request.getParameter("id");
        System.out.println("DEBUG: View user with ID = " + idStr);

        if (idStr == null || idStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "User ID is required");
            listUsers(request, response, userDAO);
            return;
        }

        try {
            int userId = Integer.parseInt(idStr);
            User user = userDAO.getUserById(userId);

            if (user == null) {
                request.setAttribute("errorMessage", "User not found with ID: " + userId);
                listUsers(request, response, userDAO);
            } else {
                request.setAttribute("user", user);
                request.getRequestDispatcher("viewUser.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid user ID format");
            listUsers(request, response, userDAO);
        }
    }
    
    private void editUserForm(HttpServletRequest request, HttpServletResponse response,
                             UserDAO userDAO) throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("DEBUG: Edit user form for ID = " + idStr);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "User ID is required");
            listUsers(request, response, userDAO);
            return;
        }
        
        try {
            int userId = Integer.parseInt(idStr);
            User user = userDAO.getUserById(userId);
            
            if (user == null) {
                request.setAttribute("errorMessage", "User not found with ID: " + userId);
                listUsers(request, response, userDAO);
            } else {
                request.setAttribute("user", user);
                request.getRequestDispatcher("editUser.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid user ID format");
            listUsers(request, response, userDAO);
        }
    }
    
    private void addUserForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("DEBUG: Showing add user form");
        request.getRequestDispatcher("addUser.jsp").forward(request, response);
    }
    
    // ========== POST METHODS ==========
    
    private void addUser(HttpServletRequest request, HttpServletResponse response,
                        UserDAO userDAO, HttpSession session) throws IOException {
        
        System.out.println("DEBUG: Adding new user");
        
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String role = request.getParameter("role");
        String pointsStr = request.getParameter("currentPoints");
        
        System.out.println("DEBUG: User data - Name: " + name + ", Email: " + email + 
                         ", Role: " + role + ", Points: " + pointsStr);
        
        // Validate required fields
        if (name == null || name.trim().isEmpty() || 
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            
            session.setAttribute("errorMessage", "Name, Email and Password are required fields");
            response.sendRedirect("AdminUserServlet?action=add");
            return;
        }
        
        User user = new User();
        user.setName(name.trim());
        user.setEmail(email.trim());
        user.setPassword(password.trim()); // Note: In production, hash this password
        user.setPhone(phone != null ? phone.trim() : "");
        user.setAddress(address != null ? address.trim() : "");
        user.setRole(role != null ? role.trim() : "user");
        
        try {
            int points = pointsStr != null && !pointsStr.trim().isEmpty() ? Integer.parseInt(pointsStr) : 0;
            user.setCurrentPoints(points);
        } catch (NumberFormatException e) {
            user.setCurrentPoints(0);
        }
        
        boolean success = userDAO.addUserAdmin(user);
        
        if (success) {
            System.out.println("DEBUG: User added successfully");
            session.setAttribute("successMessage", "User '" + user.getName() + "' added successfully!");
        } else {
            System.out.println("DEBUG: Failed to add user");
            session.setAttribute("errorMessage", "Failed to add user. Email might already exist.");
        }
        
        response.sendRedirect("AdminUserServlet");
    }
    
    private void updateUser(HttpServletRequest request, HttpServletResponse response,
                           UserDAO userDAO, HttpSession session) throws IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("DEBUG: Updating user ID = " + idStr);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "User ID is required");
            response.sendRedirect("AdminUserServlet");
            return;
        }
        
        try {
            int userId = Integer.parseInt(idStr);
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String address = request.getParameter("address");
            String role = request.getParameter("role");
            String pointsStr = request.getParameter("currentPoints");
            
            System.out.println("DEBUG: Update data - Name: " + name + ", Email: " + email + 
                             ", Role: " + role + ", Points: " + pointsStr);
            
            // Validate required fields
            if (name == null || name.trim().isEmpty() || 
                email == null || email.trim().isEmpty()) {
                
                session.setAttribute("errorMessage", "Name and Email are required fields");
                response.sendRedirect("AdminUserServlet?action=edit&id=" + userId);
                return;
            }
            
            User user = new User();
            user.setUserId(userId);
            user.setName(name.trim());
            user.setEmail(email.trim());
            user.setPhone(phone != null ? phone.trim() : "");
            user.setAddress(address != null ? address.trim() : "");
            user.setRole(role != null ? role.trim() : "user");
            
            try {
                int points = pointsStr != null && !pointsStr.trim().isEmpty() ? Integer.parseInt(pointsStr) : 0;
                user.setCurrentPoints(points);
            } catch (NumberFormatException e) {
                // Keep existing points if invalid input
                User existingUser = userDAO.getUserById(userId);
                user.setCurrentPoints(existingUser != null ? existingUser.getCurrentPoints() : 0);
            }
            
            boolean success = userDAO.updateUserAdmin(user);
            
            if (success) {
                System.out.println("DEBUG: User updated successfully");
                session.setAttribute("successMessage", "User '" + user.getName() + "' updated successfully!");
            } else {
                System.out.println("DEBUG: Failed to update user");
                session.setAttribute("errorMessage", "Failed to update user. Please try again.");
            }
            
            response.sendRedirect("AdminUserServlet");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid user ID format");
            response.sendRedirect("AdminUserServlet");
        }
    }
    
    private void deleteUser(HttpServletRequest request, HttpServletResponse response,
                           UserDAO userDAO, HttpSession session) throws IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("DEBUG: Deleting user ID = " + idStr);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "User ID is required");
            response.sendRedirect("AdminUserServlet");
            return;
        }
        
        try {
            int userId = Integer.parseInt(idStr);
            
            // Check if user can be deleted
            if (!userDAO.isUserDeletable(userId)) {
                session.setAttribute("errorMessage", "Cannot delete user. This user has active records.");
                response.sendRedirect("AdminUserServlet");
                return;
            }
            
            // Get user name for success message
            User user = userDAO.getUserById(userId);
            String userName = user != null ? user.getName() : "User";
            
            // Prevent admin from deleting themselves
            User loggedInUser = (User) session.getAttribute("user");
            if (loggedInUser != null && loggedInUser.getUserId() == userId) {
                session.setAttribute("errorMessage", "You cannot delete your own account while logged in.");
                response.sendRedirect("AdminUserServlet");
                return;
            }
            
            boolean success = userDAO.deleteUser(userId);
            
            if (success) {
                System.out.println("DEBUG: User deleted successfully");
                session.setAttribute("successMessage", "User '" + userName + "' deleted successfully!");
            } else {
                System.out.println("DEBUG: Failed to delete user");
                session.setAttribute("errorMessage", "Failed to delete user. Please try again.");
            }
            
            response.sendRedirect("AdminUserServlet");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid user ID format");
            response.sendRedirect("AdminUserServlet");
        }
    }
}