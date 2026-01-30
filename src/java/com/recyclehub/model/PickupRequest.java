package com.recyclehub.model;

import java.sql.Date;
import java.io.Serializable;

public class PickupRequest implements Serializable {

    private int requestId;
    private int userId;
    private Date requestDate;
    private Date pickupDate;
    private String pickupTime;
    private String status;

    // Joined fields (ADMIN VIEW)
    private String userName;
    private String collectorName;
    private Integer collectorId;

    public PickupRequest() {}

    public PickupRequest(int requestId, int userId, Date requestDate,
                          Date pickupDate, String pickupTime, String status) {
        this.requestId = requestId;
        this.userId = userId;
        this.requestDate = requestDate;
        this.pickupDate = pickupDate;
        this.pickupTime = pickupTime;
        this.status = status;
    }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public Date getRequestDate() { return requestDate; }
    public void setRequestDate(Date requestDate) { this.requestDate = requestDate; }

    public Date getPickupDate() { return pickupDate; }
    public void setPickupDate(Date pickupDate) { this.pickupDate = pickupDate; }

    public String getPickupTime() { return pickupTime; }
    public void setPickupTime(String pickupTime) { this.pickupTime = pickupTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getCollectorName() { return collectorName; }
    public void setCollectorName(String collectorName) { this.collectorName = collectorName; }

    public Integer getCollectorId() { return collectorId; }
    public void setCollectorId(Integer collectorId) { this.collectorId = collectorId; }
}
