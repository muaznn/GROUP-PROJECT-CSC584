package com.recyclehub.model;

import java.io.Serializable;

public class Collector implements Serializable {
    private int collectorId;
    private String name;
    private String phone;
    private String plateNumber;
    private String status; // e.g., "Available", "Busy"
    private boolean deletable; // Add this field

    public Collector() {System.out.println("DEBUG: CollectorDAO constructor called");}

    public Collector(int collectorId, String name, String phone, String plateNumber, String status, boolean deletable) {
        this.collectorId = collectorId;
        this.name = name;
        this.phone = phone;
        this.plateNumber = plateNumber; 
        this.status = status; 
        this.deletable = deletable; 
    }

    public int getCollectorId() { return collectorId; }
    public void setCollectorId(int collectorId) { this.collectorId = collectorId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public boolean isDeletable() {return deletable;}
    public void setDeletable(boolean deletable) {this.deletable = deletable;}
}
