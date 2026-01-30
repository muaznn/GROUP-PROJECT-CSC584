package com.recyclehub.model;

import java.io.Serializable;
import java.sql.Date;

public class Redemption implements Serializable {
    private int redemptionId;
    private int userId;
    private int catalogId;
    private Date redeemDate;
    private String status;

    public Redemption() {}

    public Redemption(int userId, int catalogId, String status) {
        this.userId = userId;
        this.catalogId = catalogId;
        this.status = status;
    }

    public int getRedemptionId() { return redemptionId; }
    public void setRedemptionId(int redemptionId) { this.redemptionId = redemptionId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getCatalogId() { return catalogId; }
    public void setCatalogId(int catalogId) { this.catalogId = catalogId; }
    
    public Date getRedeemDate() { return redeemDate; }
    public void setRedeemDate(Date redeemDate) { this.redeemDate = redeemDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }



}