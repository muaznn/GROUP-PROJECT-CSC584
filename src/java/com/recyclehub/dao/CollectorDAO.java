package com.recyclehub.dao;

import com.recyclehub.model.Collector;
import com.recyclehub.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CollectorDAO {

    // Get all collectors
    public List<Collector> getAllCollectors() {
        List<Collector> list = new ArrayList<>();
        String sql = "SELECT * FROM collector ORDER BY collectorId DESC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(createCollectorFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.getAllCollectors]: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
    
    // Get collector by ID
    public Collector getCollectorById(int collectorId) {
        String sql = "SELECT * FROM collector WHERE collectorId = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, collectorId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return createCollectorFromResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.getCollectorById]: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
    
    // Add new collector
    public int addCollector(Collector collector) {
        String sql = "INSERT INTO collector (name, phone, plateNumber, status) VALUES (?, ?, ?, ?)";
        int generatedId = -1;
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, collector.getName());
            ps.setString(2, collector.getPhone());
            ps.setString(3, collector.getPlateNumber());
            ps.setString(4, collector.getStatus() != null ? collector.getStatus() : "Available");
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getInt(1);
                    }
                }
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.addCollector]: " + e.getMessage());
            e.printStackTrace();
        }
        return generatedId;
    }
    
    // Update collector
    public boolean updateCollector(Collector collector) {
        String sql = "UPDATE collector SET name = ?, phone = ?, plateNumber = ?, status = ? WHERE collectorId = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, collector.getName());
            ps.setString(2, collector.getPhone());
            ps.setString(3, collector.getPlateNumber());
            ps.setString(4, collector.getStatus());
            ps.setInt(5, collector.getCollectorId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.updateCollector]: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Delete collector
    public boolean deleteCollector(int collectorId) {
        String sql = "DELETE FROM collector WHERE collectorId = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, collectorId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.deleteCollector]: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Toggle collector status
    public boolean toggleStatus(int collectorId, String status) {
        String sql = "UPDATE collector SET status = ? WHERE collectorId = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, collectorId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.toggleStatus]: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Get available collectors
    public List<Collector> getAvailableCollectors() {
        List<Collector> list = new ArrayList<>();
        String sql = "SELECT * FROM collector WHERE status = 'Available' ORDER BY name";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                list.add(createCollectorFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.getAvailableCollectors]: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
    
    // Assign collector to request
    public boolean assignCollector(int requestId, int collectorId) {
        boolean isSuccess = false;
        
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            
            try {
                // Insert assignment
                String sqlAssign = "INSERT INTO assignment (requestId, collectorId, assignDate) VALUES (?, ?, CURRENT_DATE)";
                try (PreparedStatement ps1 = con.prepareStatement(sqlAssign)) {
                    ps1.setInt(1, requestId);
                    ps1.setInt(2, collectorId);
                    ps1.executeUpdate();
                }
                
                // Update request status
                String sqlUpdate = "UPDATE pickupRequest SET status = 'Assigned' WHERE requestId = ?";
                try (PreparedStatement ps2 = con.prepareStatement(sqlUpdate)) {
                    ps2.setInt(1, requestId);
                    ps2.executeUpdate();
                }
                
                con.commit();
                isSuccess = true;
                
            } catch (SQLException e) {
                con.rollback();
                throw e;
            }
            
        } catch (SQLException e) {
            System.err.println("ERROR [CollectorDAO.assignCollector]: " + e.getMessage());
            e.printStackTrace();
        }
        return isSuccess;
    }
    
    // Helper method to create Collector object from ResultSet
    private Collector createCollectorFromResultSet(ResultSet rs) throws SQLException {
        Collector collector = new Collector();
        collector.setCollectorId(rs.getInt("collectorId"));
        collector.setName(rs.getString("name"));
        collector.setPhone(rs.getString("phone"));
        collector.setPlateNumber(rs.getString("plateNumber"));
        collector.setStatus(rs.getString("status"));
        return collector;
    }
    
    public boolean isCollectorDeletable(int collectorId) {
    String sql = "SELECT COUNT(*) FROM Assignment WHERE collectorId = ?";
    
    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {
        
        ps.setInt(1, collectorId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            int assignmentCount = rs.getInt(1);
            System.out.println("DEBUG: Collector has " + assignmentCount + " assignments");
            return assignmentCount == 0;
        }
        
    } catch (SQLException e) {
        System.err.println("ERROR checking assignments: " + e.getMessage());
    }
    return true;
}
}