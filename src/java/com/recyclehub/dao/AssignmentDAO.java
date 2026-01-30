package com.recyclehub.dao;

import com.recyclehub.model.Assignment;
import com.recyclehub.util.DBConnection;
import java.sql.*;

public class AssignmentDAO {

    public boolean assignCollector(Assignment assignment) {
        String sql = "INSERT INTO Assignment (requestId, collectorId, assignDate) VALUES (?, ?, CURRENT_TIMESTAMP)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            
            ps.setInt(1, assignment.getRequestId());
            ps.setInt(2, assignment.getCollectorId());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}