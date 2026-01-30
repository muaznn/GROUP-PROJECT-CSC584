package com.recyclehub.controller;

import com.recyclehub.dao.PickupDetailsDAO;
import com.recyclehub.dao.PickupRequestDAO;
import com.recyclehub.model.PickupDetails;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.User;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "RequestServlet", urlPatterns = {"/RequestServlet"})
public class RequestServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 1. GET FORM DATA
            String dateStr = request.getParameter("pickupDate");
            String timeStr = request.getParameter("pickupTime");
            String specialNotes = request.getParameter("specialNotes");
            
            System.out.println("DEBUG: Received pickupDate: " + dateStr);
            System.out.println("DEBUG: Received pickupTime: " + timeStr);
            System.out.println("DEBUG: Received specialNotes: " + specialNotes);
            
            // Validate required fields
            if (dateStr == null || dateStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a pickup date.");
                request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
                return;
            }
            
            if (timeStr == null || timeStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please select a pickup time.");
                request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
                return;
            }
            
            // 2. PARSE DATE
            Date pickupDate = null;
            try {
                pickupDate = Date.valueOf(dateStr);
                
                // Check if date is in the past
                LocalDate selectedDate = pickupDate.toLocalDate();
                LocalDate today = LocalDate.now();
                
                if (selectedDate.isBefore(today)) {
                    request.setAttribute("errorMessage", "Please select a future date.");
                    request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
                    return;
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("errorMessage", "Invalid date format. Please use YYYY-MM-DD format.");
                request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
                return;
            }
            
            // 3. CREATE AND SAVE PICKUP REQUEST
            PickupRequest pickupRequest = new PickupRequest();
            pickupRequest.setUserId(user.getUserId());
            pickupRequest.setPickupDate(pickupDate);
            pickupRequest.setPickupTime(timeStr);
            pickupRequest.setStatus("PENDING");
            
            PickupRequestDAO pickupRequestDAO = new PickupRequestDAO();
            int requestId = pickupRequestDAO.createRequest(pickupRequest);
            
            if (requestId <= 0) {
                request.setAttribute("errorMessage", "Failed to create pickup request. Please try again.");
                request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
                return;
            }
            
            System.out.println("DEBUG: Created PickupRequest with ID: " + requestId);
            
            // 4. SAVE PICKUP DETAILS
            PickupDetailsDAO pickupDetailsDAO = new PickupDetailsDAO();
            boolean hasValidDetails = false;
            
            // Define material categories based on your database
            String[] materials = {"paper", "plastic", "metal", "glass", "electronics"};
            
            for (String material : materials) {
                String weightParam = "weight_" + material;
                String weightStr = request.getParameter(weightParam);
                
                if (weightStr != null && !weightStr.trim().isEmpty()) {
                    try {
                        double weight = Double.parseDouble(weightStr);
                        
                        // Only save if weight > 0
                        if (weight > 0) {
                            PickupDetails detail = new PickupDetails();
                            detail.setRequestId(requestId);
                            detail.setCategory(material.toUpperCase());
                            detail.setWeight(weight);
                            
                            // Use special notes if provided for the first material
                            if (specialNotes != null && !specialNotes.trim().isEmpty()) {
                                detail.setRemarks(specialNotes);
                            } else {
                                detail.setRemarks("Estimated by user");
                            }
                            
                            boolean saved = pickupDetailsDAO.addDetails(detail);
                            if (saved) {
                                hasValidDetails = true;
                                System.out.println("DEBUG: Saved " + material + ": " + weight + "kg");
                            }
                        }
                    } catch (NumberFormatException e) {
                        System.err.println("Invalid weight for " + material + ": " + weightStr);
                    }
                }
            }
            
            // Check if at least one material was saved
//            if (!hasValidDetails) {
//                // Rollback: Delete the pickup request since no details were added
//                pickupRequestDAO.deleteRequest(requestId);
//                request.setAttribute("errorMessage", "Please enter weight for at least one material (minimum 0.5kg).");
//                request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
//                return;
//            }
            
            // 5. SUCCESS - REDIRECT TO DASHBOARD
            session.setAttribute("successMessage", 
                "Pickup request scheduled successfully! Request ID: " + String.format("REQ%04d", requestId));
            response.sendRedirect("DashboardServlet");
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "System error: " + e.getMessage());
            request.getRequestDispatcher("requestPickup.jsp").forward(request, response);
        }
    }
}