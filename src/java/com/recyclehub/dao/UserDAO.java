package com.recyclehub.dao;

import com.recyclehub.model.User;
import com.recyclehub.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import java.sql.SQLException;

public class UserDAO {

    // 1. REGISTER USER (Create)
    public boolean registerUser(User user) {
        Connection con = null;
        PreparedStatement ps = null;
        
        // Note: Assuming you renamed the table to "Users" to avoid reserved word issues
        String sql = "INSERT INTO Users (name, password, email, address, phone, role, currentPoints) VALUES (?, ?, ?, ?, ?, ?, ?)";

        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            
            // Fill in the ? marks with data from the Bean
            ps.setString(1, user.getName());
            ps.setString(2, user.getPassword()); // In real app, hash this!
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getAddress());
            ps.setString(5, user.getPhone());
            ps.setString(6, "user"); // Default role
            ps.setInt(7, 0);         // Default points

            int result = ps.executeUpdate();
            return result > 0; // Returns true if saved successfully

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            // Always close connections to prevent memory leaks
            try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
    }

    // 2. LOGIN USER (Read)
    public User loginUser(String email, String password) {
        User user = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sql = "SELECT * FROM Users WHERE email = ? AND password = ?";

        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);

            rs = ps.executeQuery();

            if (rs.next()) {
                // If found, take data from DB and put it into a User Bean
                user = new User();
                user.setUserId(rs.getInt("userId"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setCurrentPoints(rs.getInt("currentPoints"));
                user.setAddress(rs.getString("address"));
                user.setPhone(rs.getString("phone"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        
        return user; // Returns the User object if login success, or null if failed
    }
    
    // 3. GET USER BY ID (Useful for Profile Page)
    public User getUserById(int id) {
        User user = null;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM Users WHERE userId = ?";

        try {
            con = DBConnection.getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserId(rs.getInt("userId"));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
                user.setCurrentPoints(rs.getInt("currentPoints"));
                user.setAddress(rs.getString("address"));
                user.setPhone(rs.getString("phone"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
        }
        return user;
    }
    
    // Update user details (Name, Phone, Address)
    public boolean updateUser(User user) {
        boolean isSuccess = false;
        String sql = "UPDATE Users SET name = ?, phone = ?, address = ? WHERE userId = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getAddress());
            ps.setInt(4, user.getUserId()); // identify which user to update
            
            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                isSuccess = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return isSuccess;
    }
    
    // Deduct points when a user claims a reward
    public boolean deductPoints(int userId, int pointsToDeduct) {
        boolean success = false;
        // We use a safe query that prevents points from going below zero
        String sql = "UPDATE Users SET currentPoints = currentPoints - ? WHERE userId = ? AND currentPoints >= ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, pointsToDeduct); // Subtract 500
            ps.setInt(2, userId);         // From User #1
            ps.setInt(3, pointsToDeduct); // Security check: Ensure they HAVE at least 500
            
            int rows = ps.executeUpdate();
            if (rows > 0) {
                success = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return success;
    }
    
    // Add this method to UserDAO
    public boolean addPoints(int userId, int points) {
        String sql = "UPDATE Users SET currentPoints = currentPoints + ? WHERE userId = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, points);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // 1. GET ALL USERS (for admin management)
        public List<User> getAllUsers() {
            List<User> users = new ArrayList<>();
            Connection con = null;
            PreparedStatement ps = null;
            ResultSet rs = null;

            String sql = "SELECT * FROM Users ORDER BY userId DESC";

            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement(sql);
                rs = ps.executeQuery();

                while (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("userId"));
                    user.setName(rs.getString("name"));
                    user.setEmail(rs.getString("email"));
                    user.setPassword(rs.getString("password"));
                    user.setRole(rs.getString("role"));
                    user.setCurrentPoints(rs.getInt("currentPoints"));
                    user.setAddress(rs.getString("address"));
                    user.setPhone(rs.getString("phone"));
                    users.add(user);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            } finally {
                try { 
                    if (rs != null) rs.close(); 
                    if (ps != null) ps.close(); 
                    if (con != null) con.close(); 
                } catch (Exception e) {}
            }
            return users;
        }

        // 2. UPDATE USER (admin version - can update all fields including role)
        public boolean updateUserAdmin(User user) {
            boolean isSuccess = false;
            String sql = "UPDATE Users SET name = ?, email = ?, phone = ?, address = ?, role = ?, currentPoints = ? WHERE userId = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, user.getName());
                ps.setString(2, user.getEmail());
                ps.setString(3, user.getPhone());
                ps.setString(4, user.getAddress());
                ps.setString(5, user.getRole());
                ps.setInt(6, user.getCurrentPoints());
                ps.setInt(7, user.getUserId());

                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    isSuccess = true;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return isSuccess;
        }

        // 3. DELETE USER
        public boolean deleteUser(int userId) {
            boolean isSuccess = false;
            String sql = "DELETE FROM Users WHERE userId = ?";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, userId);
                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    isSuccess = true;
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return isSuccess;
        }

        // 4. CHECK IF USER CAN BE DELETED (check for dependencies)
        public boolean isUserDeletable(int userId) {
            // For now, all users can be deleted since there's no foreign key constraints mentioned
            // You can add checks here if needed (e.g., check if user has pending requests)
            return true;
        }

        // 5. ADD USER (admin version - can set role)
        public boolean addUserAdmin(User user) {
            Connection con = null;
            PreparedStatement ps = null;

            String sql = "INSERT INTO Users (name, password, email, address, phone, role, currentPoints) VALUES (?, ?, ?, ?, ?, ?, ?)";

            try {
                con = DBConnection.getConnection();
                ps = con.prepareStatement(sql);

                ps.setString(1, user.getName());
                ps.setString(2, user.getPassword());
                ps.setString(3, user.getEmail());
                ps.setString(4, user.getAddress());
                ps.setString(5, user.getPhone());
                ps.setString(6, user.getRole());
                ps.setInt(7, user.getCurrentPoints());

                int result = ps.executeUpdate();
                return result > 0;

            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            } finally {
                try { if (ps != null) ps.close(); if (con != null) con.close(); } catch (Exception e) {}
            }
        }
    
}