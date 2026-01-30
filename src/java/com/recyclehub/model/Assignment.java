package com.recyclehub.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Assignment implements Serializable {
    private int assignId;
    private int requestId;
    private int collectorId;
    private Timestamp assignDate;

    public Assignment() {}

    public Assignment(int assignId, int requestId, int collectorId, Timestamp assignDate) {
        this.assignId = assignId;
        this.requestId = requestId;
        this.collectorId = collectorId;
        this.assignDate = assignDate;
    }

    public int getAssignId() { return assignId; }
    public void setAssignId(int assignId) { this.assignId = assignId; }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public int getCollectorId() { return collectorId; }
    public void setCollectorId(int collectorId) { this.collectorId = collectorId; }

    public Timestamp getAssignDate() { return assignDate; }
    public void setAssignDate(Timestamp assignDate) { this.assignDate = assignDate; }
}