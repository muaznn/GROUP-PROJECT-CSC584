package com.recyclehub.dao;

import com.recyclehub.model.Redemption;
import com.recyclehub.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RedemptionDAO {
    
    // Get redemptions by user ID
    public List<Redemption> getRedemptionsByUserId(int userId) {
        List<Redemption> redemptions = new ArrayList<>();
        String sql = "SELECT * FROM redemption WHERE userId = ? ORDER BY redeemDate DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Redemption redemption = new Redemption();
                redemption.setRedemptionId(rs.getInt("redemptionId"));
                redemption.setUserId(rs.getInt("userId"));
                redemption.setCatalogId(rs.getInt("catalogId"));
                redemption.setRedeemDate(rs.getDate("redeemDate"));
                redemption.setStatus(rs.getString("status"));
                redemptions.add(redemption);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return redemptions;
    }
    
    // Create new redemption
        public boolean createRedemption(int userId, int catalogId) {
        // SIMPLIFIED SQL: We let the database handle 'status' (Default ACTIVE) 
        // and 'redeemDate' (Default CURRENT_DATE) automatically.
        String sql = "INSERT INTO Redemption (userId, catalogId) VALUES (?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, userId);
            pstmt.setInt(2, catalogId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            // CRITICAL: This will print the EXACT reason to your Output Console
            System.err.println("------------- REDEMPTION INSERT ERROR -------------");
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Message: " + e.getMessage());
            System.err.println("UserId: " + userId + ", CatalogId: " + catalogId);
            System.err.println("---------------------------------------------------");
            e.printStackTrace();
            return false;
        }
    }
    
    // Check if user has already redeemed a reward
    public boolean hasUserRedeemedReward(int userId, int catalogId) {
        String sql = "SELECT COUNT(*) FROM redemption WHERE userId = ? AND catalogId = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, userId);
            ps.setInt(2, catalogId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}