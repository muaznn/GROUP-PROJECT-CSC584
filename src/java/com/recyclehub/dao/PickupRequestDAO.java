package com.recyclehub.dao;

import com.recyclehub.model.PickupDetails;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PickupRequestDAO {

    // 1. CREATE A NEW REQUEST
    // Returns the new generated Request ID so we can save details later
    public int createRequest(PickupRequest request) {
        int generatedId = -1;
        String sql = "INSERT INTO PickupRequest (userId, pickupDate, pickupTime, status) VALUES (?, ?, ?, ?)";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
             
            ps.setInt(1, request.getUserId());
            ps.setDate(2, request.getPickupDate());
            ps.setString(3, request.getPickupTime());
            ps.setString(4, "pending"); // Default status
            
            ps.executeUpdate();
            
            // Get the ID that the database just created (e.g., Request #101)
//            ResultSet rs = ps.getGeneratedKeys();
//            if (rs.next()) {
//                generatedId = rs.getInt(1);
//            }
            
            String sqlGetId = "SELECT MAX(requestId) FROM PickupRequest";
            try (PreparedStatement ps1 = con.prepareStatement(sqlGetId);
             ResultSet rs = ps1.executeQuery()) {
             
                if (rs.next()) {
                    generatedId = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return generatedId;
    }

    // 2. GET HISTORY FOR ONE USER
    public List<PickupRequest> getRequestsByUserId(int userId) {
        List<PickupRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM PickupRequest WHERE userId = ? ORDER BY pickupDate DESC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
             
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                PickupRequest r = new PickupRequest();
                r.setRequestId(rs.getInt("requestId"));
                r.setUserId(rs.getInt("userId"));
                r.setPickupDate(rs.getDate("pickupDate"));
                r.setPickupTime(rs.getString("pickupTime"));
                r.setStatus(rs.getString("status"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 3. GET ALL REQUESTS (For Admin Dashboard)
    public List<PickupRequest> getAllRequests() {
        List<PickupRequest> list = new ArrayList<>();
        String sql = "SELECT * FROM PickupRequest ORDER BY requestDate DESC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                PickupRequest r = new PickupRequest();
                r.setRequestId(rs.getInt("requestId"));
                r.setUserId(rs.getInt("userId"));
                r.setPickupDate(rs.getDate("requestDate"));
                r.setPickupTime(rs.getString("pickupTime"));
                r.setStatus(rs.getString("status"));
                list.add(r);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // 4. UPDATE STATUS (e.g., Admin clicks "Complete")
    public boolean updateStatus(int requestId, String status) {
        String sql = "UPDATE PickupRequest SET status = ? WHERE requestId = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setString(1, status);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Method to get a SINGLE request header by its ID
    public PickupRequest getRequestById(int requestId) {
        PickupRequest p = null;
        try {
            Connection conn = DBConnection.getConnection();
            String sql = "SELECT * FROM PickupRequest WHERE requestId = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, requestId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                p = new PickupRequest();
                p.setRequestId(rs.getInt("requestId"));
                p.setUserId(rs.getInt("userId"));
                p.setRequestDate(rs.getDate("requestDate")); // Ensure this matches your Bean
                p.setPickupTime(rs.getString("pickupTime"));
                p.setStatus(rs.getString("status"));
            }
            conn.close();
        } catch (Exception e) { e.printStackTrace(); }
        return p;
    }
    
    
    //for allrequest.jsp
    public List<PickupRequest> getAllRequestsForAdmin() {
    List<PickupRequest> list = new ArrayList<>();
    
    // FIXED QUERY - Simplified version to avoid JOIN issues
    String sql = "SELECT pr.*, u.name AS userName " +
                 "FROM pickupRequest pr " +
                 "JOIN users u ON pr.userId = u.userId " +
                 "ORDER BY pr.requestDate DESC";

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            PickupRequest p = new PickupRequest();

            // Standard fields
            p.setRequestId(rs.getInt("requestId"));
            p.setUserId(rs.getInt("userId"));
            p.setRequestDate(rs.getDate("requestDate"));
            p.setPickupDate(rs.getDate("pickupDate"));
            p.setPickupTime(rs.getString("pickupTime")); // Correct column name
            p.setStatus(rs.getString("status"));

            // User Name
            p.setUserName(rs.getString("userName")); 

            // Collector info - set defaults (will be populated later if needed)
            p.setCollectorName("Not Assigned");
            p.setCollectorId(0);

            System.out.println("DAO: Loaded Request ID=" + p.getRequestId() + 
                             ", User=" + p.getUserName());
            
            list.add(p);
        }
    } catch (Exception e) {
        e.printStackTrace();
        System.out.println("ERROR in getAllRequestsForAdmin: " + e.getMessage());
        return null;
    }
    return list;
}
    
        //same as before but, to fetch names in allrequest.jsp
        public PickupRequest getRequestByIds2(int id) {
            PickupRequest p = null;
            System.out.println("DEBUG: Getting request by ID: " + id);

            try (Connection conn = DBConnection.getConnection()) {
                // SIMPLIFIED QUERY FIRST - Just get basic request info
                String sql = "SELECT r.*, u.name AS userName " +
                             "FROM pickupRequest r " +
                             "JOIN Users u ON r.userId = u.userId " +
                             "WHERE r.requestId = ?";

                System.out.println("DEBUG: SQL = " + sql);

                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setInt(1, id);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            p = new PickupRequest();
                            p.setRequestId(rs.getInt("requestId"));
                            p.setUserId(rs.getInt("userId"));
                            p.setRequestDate(rs.getDate("requestDate"));
                            p.setPickupDate(rs.getDate("pickupDate")); // Add this
                            p.setPickupTime(rs.getString("pickupTime"));
                            p.setStatus(rs.getString("status"));
                            p.setUserName(rs.getString("userName"));

                            System.out.println("DEBUG: Found request - ID: " + p.getRequestId() + 
                                             ", User: " + p.getUserName() + 
                                             ", Status: " + p.getStatus());

                            // Now try to get collector info separately
                            String collectorSql = "SELECT c.name, c.collectorId " +
                                                  "FROM collector c " +
                                                  "JOIN assignment a ON c.collectorId = a.collectorId " +
                                                  "WHERE a.requestId = ?";

                            try (PreparedStatement ps2 = conn.prepareStatement(collectorSql)) {
                                ps2.setInt(1, id);
                                try (ResultSet rs2 = ps2.executeQuery()) {
                                    if (rs2.next()) {
                                        p.setCollectorName(rs2.getString("name"));
                                        p.setCollectorId(rs2.getInt("collectorId"));
                                        System.out.println("DEBUG: Found collector - " + p.getCollectorName());
                                    } else {
                                        p.setCollectorName("Not Assigned");
                                        p.setCollectorId(0);
                                        System.out.println("DEBUG: No collector assigned");
                                    }
                                }
                            }
                        } else {
                            System.out.println("DEBUG: No request found with ID: " + id);
                        }
                    }
                }
            } catch (Exception e) { 
                System.err.println("ERROR in getRequestByIds for ID " + id + ": " + e.getMessage());
                e.printStackTrace();
            }
            return p;
        }
         //same as before but, to fetch names in allrequest.jsp
        public PickupRequest getRequestByIds(int id) {
            PickupRequest p = null;
            // Use the same JOIN pattern as getAllRequestsForAdmin()
            String sql = "SELECT r.*, u.name AS userName, " +
                         "       c.name AS collectorName, c.collectorId AS assignedCollectorId " +
                         "FROM pickupRequest r " +
                         "JOIN Users u ON r.userId = u.userId " +
                         "LEFT JOIN Assignment a ON r.requestId = a.requestId " +  // Use assignment table
                         "LEFT JOIN Collector c ON a.collectorId = c.collectorId " +  // Join through assignment
                         "WHERE r.requestId = ?";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    p = new PickupRequest();
                    p.setRequestId(rs.getInt("requestId"));
                    p.setUserId(rs.getInt("userId"));
                    p.setRequestDate(rs.getDate("requestDate"));
                    p.setPickupTime(rs.getString("pickupTime"));
                    p.setStatus(rs.getString("status"));
                    p.setUserName(rs.getString("userName"));
                    p.setCollectorName(rs.getString("collectorName"));

                    // Get collectorId from the JOIN result
                    int cId = rs.getInt("assignedCollectorId");
                    if (!rs.wasNull()) {
                        p.setCollectorId(cId);
                    }
                }
            } catch (Exception e) { 
                e.printStackTrace(); 
            }
            return p;
        }
        
        public List<PickupDetails> getDetailsByRequestId(int id) {
            List<PickupDetails> list = new ArrayList<>();
            String sql = "SELECT * FROM pickupDetails WHERE requestId = ?";

            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, id);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    PickupDetails d = new PickupDetails();
                    d.setDetailsId(rs.getInt("detailsId")); // Assuming you have an ID
                    d.setCategory(rs.getString("category"));
                    d.setWeight(rs.getDouble("weight")); // Or Double, depending on DB
                    d.setRemarks(rs.getString("remarks"));
                    list.add(d);
                }
            } catch (Exception e) { e.printStackTrace(); }
            return list;
        }
        
        // Only add this method to PickupRequestDAO
            public boolean assignCollector(int requestId, int collectorId) {
            System.out.println("=== assignCollector START ===");
            System.out.println("Parameters: requestId=" + requestId + ", collectorId=" + collectorId);

            Connection conn = null;
            PreparedStatement ps = null;

            try {
                conn = DBConnection.getConnection();
                System.out.println("DEBUG: Database connection established");

                // Try UPDATE first (if assignment exists)
                String updateSql = "UPDATE Assignment SET collectorId = ?, assignDate = CURRENT_TIMESTAMP WHERE requestId = ?";
                System.out.println("DEBUG: SQL: " + updateSql);

                ps = conn.prepareStatement(updateSql);
                ps.setInt(1, collectorId);
                ps.setInt(2, requestId);

                int rowsUpdated = ps.executeUpdate();
                System.out.println("DEBUG: Rows updated: " + rowsUpdated);

                if (rowsUpdated == 0) {
                    System.out.println("DEBUG: No rows updated, trying INSERT");
                    ps.close();

                    // No assignment exists, try INSERT
                    String insertSql = "INSERT INTO Assignment (requestId, collectorId, assignDate) VALUES (?, ?, CURRENT_TIMESTAMP)";
                    System.out.println("DEBUG: SQL: " + insertSql);

                    ps = conn.prepareStatement(insertSql);
                    ps.setInt(1, requestId);
                    ps.setInt(2, collectorId);

                    int rowsInserted = ps.executeUpdate();
                    System.out.println("DEBUG: Rows inserted: " + rowsInserted);

                    if (rowsInserted == 0) {
                        System.out.println("DEBUG: INSERT also failed");
                        return false;
                    }
                }

                // Update request status
                String statusSql = "UPDATE pickupRequest SET status = 'Assigned' WHERE requestId = ?";
                PreparedStatement statusStmt = conn.prepareStatement(statusSql);
                statusStmt.setInt(1, requestId);
                statusStmt.executeUpdate();
                statusStmt.close();

                System.out.println("=== assignCollector SUCCESS ===");
                return true;

            } catch (SQLException e) {
                System.err.println("ERROR in assignCollector: " + e.getMessage());
                System.err.println("SQL State: " + e.getSQLState());
                System.err.println("Error Code: " + e.getErrorCode());
                e.printStackTrace();

                return false;
            } finally {
                try { if (ps != null) ps.close(); } catch (SQLException e) {}
                try { if (conn != null) conn.close(); } catch (SQLException e) {}
                System.out.println("=== assignCollector END ===");
            }
        }


        // Add this method to PickupRequestDAO
        public boolean updateCollector(int requestId, int collectorId) {
            String sql = "UPDATE PickupRequest SET collectorId = ? WHERE requestId = ?";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, collectorId);
                ps.setInt(2, requestId);
                return ps.executeUpdate() > 0;

            } catch (SQLException e) {
                e.printStackTrace();
                return false;
            }
        }
        
        // 1. Get requests by a single status (e.g., "Pending" or "Completed")
        public List<PickupRequest> getRequestsByStatus(String status) {
            List<PickupRequest> list = new ArrayList<>();
            String sql = "SELECT * FROM pickupRequests WHERE status = ? ORDER BY requestDate DESC";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setString(1, status);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    // ... (Your existing code to map ResultSet to PickupRequest object) ...
                    // list.add(p);
                }
            } catch (Exception e) { e.printStackTrace(); }
            return list;
        }

        // 2. Get requests that are currently active/scheduled (Status is 'Assigned' OR 'Scheduled')
        public List<PickupRequest> getScheduledRequests() {
            List<PickupRequest> list = new ArrayList<>();
            // This query gets both "Assigned" and "Scheduled" statuses
            String sql = "SELECT * FROM pickupRequests WHERE status IN ('Assigned', 'Scheduled') ORDER BY requestDate DESC";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    // ... (Your existing code to map ResultSet to PickupRequest object) ...
                    // list.add(p);
                }
            } catch (Exception e) { e.printStackTrace(); }
            return list;
        }

    
    
}