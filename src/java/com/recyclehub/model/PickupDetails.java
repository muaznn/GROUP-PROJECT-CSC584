package com.recyclehub.model;

import java.io.Serializable;

public class PickupDetails implements Serializable {
    private int detailsId;
    private int requestId;
    private String category; // Plastic, Paper, etc.
    private double weight;
    private String remarks;

    public PickupDetails() {}

    public PickupDetails(int detailsId, int requestId, String category, double weight, String remarks) {
        this.detailsId = detailsId;
        this.requestId = requestId;
        this.category = category;
        this.weight = weight;
        this.remarks = remarks;
    }

    public int getDetailsId() { return detailsId; }
    public void setDetailsId(int detailsId) { this.detailsId = detailsId; }

    public int getRequestId() { return requestId; }
    public void setRequestId(int requestId) { this.requestId = requestId; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public double getWeight() { return weight; }
    public void setWeight(double weight) { this.weight = weight; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }
}