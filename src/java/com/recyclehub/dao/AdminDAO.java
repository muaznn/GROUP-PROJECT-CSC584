package com.recyclehub.dao;

import com.recyclehub.model.PickupRequest;
import com.recyclehub.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDate;

public class AdminDAO {

    // 1. STAT: Total Requests (All time)
    public int getTotalRequestsCount() {
        int count = 0;
        try {
            Connection conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM PickupRequest"; // Adjust table name if singular
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        return count;
    }

    // 2. STAT: Pending Requests
    public int getPendingRequestsCount() {
        int count = 0;
        try {
            Connection conn = DBConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM PickupRequest WHERE status = 'Pending'";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        return count;
    }

    // 3. STAT: Active Collectors
    public int getActiveCollectorsCount() {
        int count = 0;
        try {
            Connection conn = DBConnection.getConnection();
            // Assuming all in table are active, or add WHERE status='Active'
            String sql = "SELECT COUNT(*) FROM collector"; 
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) count = rs.getInt(1);
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        return count;
    }

    // 4. STAT: Recycled This Month (kg)
    public double getMonthlyRecycledWeight() {
        double total = 0;
        try {
            Connection conn = DBConnection.getConnection();
            // Sum weight for Completed requests in the CURRENT MONTH
            // Note: Syntax depends on DB (MySQL/Postgres/Derby). This is standard SQL.
            String sql = "SELECT SUM(d.weight) " +
                         "FROM PickupDetails d " +
                         "JOIN PickupRequest p ON d.requestId = p.requestId " +
                         "WHERE p.status = 'Completed' " +
                         "AND MONTH(p.requestDate) = MONTH(CURRENT_DATE) " +
                         "AND YEAR(p.requestDate) = YEAR(CURRENT_DATE)";
                         
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) total = rs.getDouble(1);
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        return total;
    }

    // 5. LIST: Recent 5 Requests (For the table)
    public List<PickupRequest> getRecentRequests() {
        List<PickupRequest> list = new ArrayList<>();
        try {
            Connection conn = DBConnection.getConnection();
//            String sql2 = "SELECT *, FROM PickupRequest ORDER BY requestDate DESC FETCH FIRST 5 ROWS ONLY";
            String sql = "SELECT pr.*, u.name AS userName "+
                 "FROM pickupRequest pr " +
                 "JOIN Users u ON pr.userId = u.userId " +
                "ORDER BY pr.requestDate DESC FETCH FIRST 5 ROWS ONLY";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                PickupRequest p = new PickupRequest();
                p.setRequestId(rs.getInt("requestId"));
                p.setUserName(rs.getString("userName"));
                p.setRequestDate(rs.getDate("requestDate"));
                p.setStatus(rs.getString("status"));
                // Note: Materials list isn't in this table, handled by "View" button
                list.add(p);
            }
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}