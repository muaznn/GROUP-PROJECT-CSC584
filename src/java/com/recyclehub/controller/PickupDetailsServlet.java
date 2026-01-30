package com.recyclehub.controller;

import com.recyclehub.dao.PickupRequestDAO;
import com.recyclehub.dao.PickupDetailsDAO;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.PickupDetails;
import com.recyclehub.model.User; // ADD THIS IMPORT
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PickupDetailsServlet")
public class PickupDetailsServlet extends HttpServlet {
    private PickupRequestDAO pickupRequestDAO = new PickupRequestDAO();
    private PickupDetailsDAO pickupDetailsDAO = new PickupDetailsDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check if user is logged in - look for User object
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp?message=Please login first");
            return;
        }

        // Get User object from session
        User user = (User) session.getAttribute("user");
        int userId = user.getUserId(); // Assuming User model has getUserId()
        String userRole = user.getRole();

        // Get request ID from parameter
        String requestIdParam = request.getParameter("id");

        if (requestIdParam == null || requestIdParam.isEmpty()) {
            if ("admin".equalsIgnoreCase(userRole)) {
                response.sendRedirect("AllRequestsServlet");
            } else {
                response.sendRedirect("DashboardServlet");
            }
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdParam);
            
            // REMOVED THIS LINE - userId is already defined above
            // int userId = Integer.parseInt(userIdStr);
            
            // Fetch pickup request
            PickupRequest pickupRequest = pickupRequestDAO.getRequestByIds(requestId);
            
            if (pickupRequest == null) {
                request.setAttribute("errorMessage", "Pickup request not found.");
                if ("admin".equalsIgnoreCase(userRole)) {
                    request.getRequestDispatcher("allRequests.jsp").forward(request, response);
                } else {
                    request.getRequestDispatcher("dashboard.jsp").forward(request, response);
                }
                return;
            }
            
            // Check authorization - user can only view their own requests unless admin
            boolean isAdmin = "admin".equalsIgnoreCase(userRole);
            boolean isOwner = pickupRequest.getUserId() == userId;
            
            if (!isAdmin && !isOwner) {
                request.setAttribute("errorMessage", "You are not authorized to view this request.");
                request.getRequestDispatcher("DashboardServlet").forward(request, response);
                return;
            }
            
            // Fetch pickup details
            List<PickupDetails> detailsList = pickupDetailsDAO.getDetailsByRequestId(requestId);
            
            // Calculate totals
            double totalWeight = 0.0;
            if (detailsList != null) {
                for (PickupDetails detail : detailsList) {
                    totalWeight += detail.getWeight();
                }
            }
            
            // Calculate points
            int totalPoints = 0;
            if (detailsList != null) {
                for (PickupDetails detail : detailsList) {
                    totalPoints += calculatePoints(detail.getWeight(), detail.getCategory());
                }
            }
            
            // Set attributes for JSP
            request.setAttribute("pickupRequest", pickupRequest);
            request.setAttribute("detailsList", detailsList);
            request.setAttribute("totalWeight", totalWeight);
            request.setAttribute("totalCO2", totalWeight * 1.33);
            request.setAttribute("totalPoints", totalPoints);
            
            // Add user info to session for JSP
            request.setAttribute("currentUserId", userId);
            request.setAttribute("currentUserRole", userRole);
            
            // Forward to appropriate JSP based on role
            if (isAdmin) {
                request.getRequestDispatcher("adminPickupDetails.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("pickupDetails.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid request ID format.");
            if ("admin".equalsIgnoreCase(userRole)) {
                request.getRequestDispatcher("allRequests.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("dashboard.jsp").forward(request, response);
            }
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Get User object from session
        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();
        String userRole = user.getRole();
        
        // Only users can cancel their own requests
        String action = request.getParameter("action");
        
        if ("cancel".equals(action)) {
            String requestIdParam = request.getParameter("requestId");
            
            if (requestIdParam != null && !requestIdParam.isEmpty()) {
                try {
                    int requestId = Integer.parseInt(requestIdParam);
                    
                    // Get the request to verify ownership
                    PickupRequest pickupRequest = pickupRequestDAO.getRequestByIds(requestId);
                    
                    if (pickupRequest != null) {
                        // Verify ownership
                        if (pickupRequest.getUserId() == userId) {
                            // Check if status is Pending
                            if ("Pending".equalsIgnoreCase(pickupRequest.getStatus())) {
                                // Cancel the request
                                boolean success = pickupRequestDAO.updateStatus(requestId, "Cancelled");
                                
                                if (success) {
                                    session.setAttribute("successMessage", "Pickup request cancelled successfully.");
                                } else {
                                    session.setAttribute("errorMessage", "Failed to cancel pickup request.");
                                }
                            } else {
                                session.setAttribute("errorMessage", "Only pending requests can be cancelled.");
                            }
                        } else {
                            session.setAttribute("errorMessage", "You are not authorized to cancel this request.");
                        }
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("errorMessage", "Invalid request ID.");
                }
            }
            
            // Redirect back to dashboard after cancellation attempt
            response.sendRedirect("DashboardServlet");
        }
    }
    
    // Points calculation helper
    private int calculatePoints(double weight, String category) {
        double pointsPerKg = 10.0;
        
        if (category != null) {
            String catLower = category.toLowerCase();
            
            if (catLower.contains("plastic")) {
                pointsPerKg = 12.0;
            } else if (catLower.contains("paper") || catLower.contains("cardboard")) {
                pointsPerKg = 6.0;
            } else if (catLower.contains("glass")) {
                pointsPerKg = 8.0;
            } else if (catLower.contains("metal") || catLower.contains("aluminum")) {
                pointsPerKg = 15.0;
            } else if (catLower.contains("e-waste") || catLower.contains("electronic")) {
                pointsPerKg = 20.0;
            }
        }
        
        return (int) Math.round(weight * pointsPerKg);
    }
}