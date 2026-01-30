package com.recyclehub.controller;

import com.recyclehub.dao.PickupRequestDAO;
import com.recyclehub.dao.PickupDetailsDAO;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.PickupDetails;
import com.recyclehub.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/DashboardServlet"})
public class DashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Check if user is logged in
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 2. Initialize DAOs
            PickupRequestDAO requestDAO = new PickupRequestDAO();
            PickupDetailsDAO detailsDAO = new PickupDetailsDAO();
            
            // 3. Fetch pickup requests for this user
            List<PickupRequest> pickupRequests = requestDAO.getRequestsByUserId(user.getUserId());
            
            // 4. Calculate statistics
            int totalPickups = 0;
            double totalWeight = 0.0;
            int totalPoints = 0;
            
            if (pickupRequests != null && !pickupRequests.isEmpty()) {
                totalPickups = pickupRequests.size();
                
                // OPTION A: Calculate weight from all user details (using getAllDetailsForUser)
                List<PickupDetails> allUserDetails = detailsDAO.getAllDetailsForUser(user.getUserId());
                
                for (PickupDetails detail : allUserDetails) {
                    totalWeight += detail.getWeight();
                }
                
                // OPTION B: Or calculate weight request by request
                /*
                for (PickupRequest requestItem : pickupRequests) {
                    List<PickupDetails> details = detailsDAO.getDetailsByRequestId(requestItem.getRequestId());
                    for (PickupDetails detail : details) {
                        totalWeight += detail.getWeight();
                    }
                }
                */
                
                // Calculate points (10 points per kg recycled)
                totalPoints = (int)(totalWeight * 10);
            }
            
            // 5. If user has points in their profile, use the higher value
            if (user.getCurrentPoints() > totalPoints) {
                totalPoints = user.getCurrentPoints();
            }
            
            // 6. Debug output
            System.out.println("=== DASHBOARD DATA ===");
            System.out.println("User: " + user.getName() + " (ID: " + user.getUserId() + ")");
            System.out.println("Total Pickup Requests: " + totalPickups);
            System.out.println("Total Weight Recycled: " + String.format("%.2f", totalWeight) + " kg");
            System.out.println("Total Eco Points: " + totalPoints);
            System.out.println("======================");
            
            // 7. Attach data to the request (exactly what your JSP needs)
            request.setAttribute("pickupRequests", pickupRequests);
            request.setAttribute("totalPickups", totalPickups);
            request.setAttribute("totalWeight", totalWeight);
            request.setAttribute("totalPoints", totalPoints);
            
            // 8. Send to JSP
            request.getRequestDispatcher("userDashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            // Handle errors gracefully
            request.setAttribute("error", "Error loading dashboard data. Please try again.");
            request.setAttribute("totalPickups", 0);
            request.setAttribute("totalWeight", 0.0);
            request.setAttribute("totalPoints", user != null ? user.getCurrentPoints() : 0);
            request.getRequestDispatcher("userDashboard.jsp").forward(request, response);
        }
    }
}