package com.recyclehub.dao;

import com.recyclehub.model.PickupDetails;
import com.recyclehub.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PickupDetailsDAO {

    public boolean addDetails(PickupDetails details) {
        String sql = "INSERT INTO PickupDetails (requestId, category, weight, remarks) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, details.getRequestId());
            ps.setString(2, details.getCategory());
            ps.setDouble(3, details.getWeight());
            ps.setString(4, details.getRemarks());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get items for a specific request ID
    public List<PickupDetails> getDetailsByRequestId(int requestId) {
        List<PickupDetails> list = new ArrayList<>();
        String sql = "SELECT * FROM PickupDetails WHERE requestId = ?";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, requestId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PickupDetails d = new PickupDetails();
                d.setDetailsId(rs.getInt("detailsId"));
                d.setRequestId(rs.getInt("requestId"));
                d.setCategory(rs.getString("category"));
                d.setWeight(rs.getDouble("weight"));
                d.setRemarks(rs.getString("remarks"));
                list.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public List<PickupDetails> getAllDetailsForUser(int userId) {
        List<PickupDetails> details = new ArrayList<>();
        String sql = "SELECT pd.* FROM pickupDetails pd " +
                     "JOIN pickupRequest pr ON pd.requestId = pr.requestId " +
                     "WHERE pr.userId = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                PickupDetails detail = new PickupDetails();
                detail.setDetailsId(rs.getInt("detailsId"));
                detail.setRequestId(rs.getInt("requestId"));
                detail.setCategory(rs.getString("category"));
                detail.setWeight(rs.getDouble("weight"));
                detail.setRemarks(rs.getString("remarks"));
                details.add(detail);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return details;
    }
    
}