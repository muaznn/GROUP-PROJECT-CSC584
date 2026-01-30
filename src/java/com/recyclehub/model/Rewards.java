package com.recyclehub.model;

import java.io.Serializable;
import java.sql.Date;

public class Rewards implements Serializable {
    private int catalogId;
    private String rewardName;
    private String description;
    private int pointCost;
    private boolean isActive;

    public Rewards() {}

    public Rewards(int catalogId, String rewardName, String description, int pointCost, boolean isActive) {
        this.catalogId = catalogId;
        this.rewardName = rewardName;
        this.description = description;
        this.pointCost = pointCost;
        this.isActive = isActive;
    }

    public int getCatalogId() { return catalogId; }
    public void setCatalogId(int catalogId) { this.catalogId = catalogId; }

    public String getRewardName() { return rewardName; }
    public void setRewardName(String rewardsName) { this.rewardName = rewardName; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getPointCost() { return pointCost; }
    public void setPointCost(int pointCost) { this.pointCost = pointCost; }

    public boolean getIsActive() { return isActive;}
    public void setIsActive(boolean isActive) { this.isActive = isActive; }

}