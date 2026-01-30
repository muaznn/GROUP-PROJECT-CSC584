package com.recyclehub.dao;

import com.recyclehub.model.Rewards;
import com.recyclehub.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RewardsDAO {

    // Get all active rewards
    public List<Rewards> getAllActiveRewards() {
        List<Rewards> rewards = new ArrayList<>();
        String sql = "SELECT * FROM rewardCatalog WHERE isActive = TRUE ORDER BY pointCost ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Rewards reward = new Rewards();
                reward.setCatalogId(rs.getInt("catalogId"));
                reward.setRewardName(rs.getString("rewardName"));
                reward.setPointCost(rs.getInt("pointCost"));
                reward.setDescription(rs.getString("description"));
                reward.setIsActive(rs.getBoolean("isActive"));
                rewards.add(reward);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rewards;
    }
    
    // Get reward by ID
    // In RewardsDAO.java
public Rewards getRewardById(int rewardsId) {
    Rewards reward = null;
    String sql = "SELECT * FROM rewardCatalog WHERE catalogId = ?";
    
    // DEBUG PRINT
    System.out.println("--- DEBUG: Looking for Reward ID: " + rewardsId + " ---");

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        
        ps.setInt(1, rewardsId);
        ResultSet rs = ps.executeQuery();
        
        if (rs.next()) {
            reward = new Rewards();
            reward.setCatalogId(rs.getInt("catalogId"));
            
            String name = rs.getString("rewardName");
            // DEBUG PRINT
            System.out.println("--- DEBUG: Found Reward! Name from DB is: " + name);
            
            reward.setRewardName(name);
            reward.setPointCost(rs.getInt("pointCost"));
            reward.setDescription(rs.getString("description"));
            reward.setIsActive(rs.getBoolean("isActive"));
        } else {
            System.out.println("--- DEBUG: No Reward found for ID: " + rewardsId);
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return reward;
}
}