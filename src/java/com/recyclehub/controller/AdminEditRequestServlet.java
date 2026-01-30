package com.recyclehub.controller;

import com.recyclehub.dao.PickupDetailsDAO;
import com.recyclehub.dao.PickupRequestDAO;
import com.recyclehub.dao.CollectorDAO;  // Add this import
import com.recyclehub.dao.UserDAO;
import com.recyclehub.model.PickupDetails;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.Collector;  // Add this import
import com.recyclehub.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminEditRequestServlet", urlPatterns = {"/AdminEditRequestServlet"})
public class AdminEditRequestServlet extends HttpServlet {

    // 1. SHOW THE PAGE
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("=== DEBUG: AdminEditRequestServlet.doGet() START ===");

        // Security Check
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        System.out.println("DEBUG: id parameter = " + idStr);

        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("AllRequestsServlet");
            return;
        }

        try {
            int requestId = Integer.parseInt(idStr);
            System.out.println("DEBUG: Parsed requestId = " + requestId);

            PickupRequestDAO requestDAO = new PickupRequestDAO();
            PickupDetailsDAO detailsDAO = new PickupDetailsDAO();
            CollectorDAO collectorDAO = new CollectorDAO();

            // A. Get the Header
            System.out.println("DEBUG: Calling getRequestByIds(" + requestId + ")");
            PickupRequest req = requestDAO.getRequestByIds(requestId);

            // ADD DEBUG TO REQUEST
            request.setAttribute("debug_info", "Request ID: " + requestId + 
                                 ", Request object: " + (req != null ? "NOT NULL" : "NULL"));

            if (req == null) {
                System.out.println("ERROR: No request found with ID " + requestId);
                request.setAttribute("error", "No request found with ID " + requestId);
                request.getRequestDispatcher("error.jsp").forward(request, response);
                return;
            }

            // DEBUG: Check what fields we got
            System.out.println("DEBUG: Request fields:");
            System.out.println("  - ID: " + req.getRequestId());
            System.out.println("  - User ID: " + req.getUserId());
            System.out.println("  - User Name: " + req.getUserName());
            System.out.println("  - Collector Name: " + req.getCollectorName());
            System.out.println("  - Status: " + req.getStatus());

            // B. Get the Items
            System.out.println("DEBUG: Getting details for request " + requestId);
            List<PickupDetails> details = detailsDAO.getDetailsByRequestId(requestId);
            System.out.println("DEBUG: details list = " + (details != null ? "NOT NULL, size=" + details.size() : "NULL"));

            // C. Get all collectors for the dropdown
            System.out.println("DEBUG: Getting all collectors");
            List<Collector> collectors = collectorDAO.getAllCollectors();
            System.out.println("DEBUG: collectors list = " + (collectors != null ? "NOT NULL, size=" + collectors.size() : "NULL"));

            // Use the same attribute names as expected in JSP
            request.setAttribute("request", req);
            request.setAttribute("detailsList", details);
            request.setAttribute("collectorList", collectors);

            System.out.println("DEBUG: Attributes set, forwarding to adminEditRequest.jsp");
            request.getRequestDispatcher("adminEditRequest.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            System.err.println("ERROR: Invalid ID format: " + idStr);
            e.printStackTrace();
            response.sendRedirect("AllRequestsServlet");
        } catch (Exception e) {
            System.err.println("ERROR in doGet: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("AllRequestsServlet");
        }

        System.out.println("=== DEBUG: AdminEditRequestServlet.doGet() END ===");
    }

    // 2. HANDLE STATUS UPDATES
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ... (Your existing security check) ...
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String requestIdStr = request.getParameter("requestId");

        if (requestIdStr == null || requestIdStr.trim().isEmpty()) {
            response.sendRedirect("AllRequestsServlet");
            return;
        }

        try {
            int requestId = Integer.parseInt(requestIdStr);
            PickupRequestDAO dao = new PickupRequestDAO();

            if ("status".equals(action)) {
                // --- START OF NEW REWARD LOGIC ---
                String newStatus = request.getParameter("status");

                // 1. Check if we are marking it as COMPLETED
                if ("Completed".equalsIgnoreCase(newStatus)) {

                    // 2. Get current request data to check previous status (Prevent double rewarding)
                    PickupRequest currentReq = dao.getRequestByIds(requestId);

                    if (currentReq != null && !"Completed".equalsIgnoreCase(currentReq.getStatus())) {

                        // 3. Calculate Total Weight
                        PickupDetailsDAO detailsDAO = new PickupDetailsDAO();
                        List<PickupDetails> items = detailsDAO.getDetailsByRequestId(requestId);

                        double totalWeight = 0.0;
                        if (items != null) {
                            for (PickupDetails item : items) {
                                // ASSUMPTION: getWeight() exists and returns double or int
                                // If your field is named 'quantity', change this to item.getQuantity()
                                totalWeight += item.getWeight(); 
                            }
                        }

                        // 4. Calculate Points (Example: 10 points per 1 unit of weight)
                        int pointsToAward = (int) (totalWeight * 10);

                        // Fallback: If weight is 0 or missing, give a flat 50 points
                        if (pointsToAward == 0) pointsToAward = 50; 

                        // 5. Add Points to User
                        UserDAO userDAO = new UserDAO();
                        boolean pointsAdded = userDAO.addPoints(currentReq.getUserId(), pointsToAward);

                        if (pointsAdded) {
                            System.out.println("DEBUG: Awarded " + pointsToAward + " points to User ID " + currentReq.getUserId());
                        } else {
                            System.err.println("ERROR: Failed to award points.");
                        }
                    }
                }
                // --- END OF NEW REWARD LOGIC ---

                // Proceed to update the status in Database as usual
                boolean success = dao.updateStatus(requestId, newStatus);
                if (success) {
                    response.sendRedirect("AdminEditRequestServlet?id=" + requestId + "&msg=updated");
                } else {
                    response.sendRedirect("AdminEditRequestServlet?id=" + requestId + "&msg=error");
                }

            } else if ("assign".equals(action)) {
                // ... (Your existing assign logic remains exactly the same) ...
                // (Copy your existing assign code here)
                 String collectorIdStr = request.getParameter("collectorId");
                if (collectorIdStr != null && !collectorIdStr.trim().isEmpty()) {
                    int collectorId = Integer.parseInt(collectorIdStr);
                    boolean success = dao.assignCollector(requestId, collectorId);
                    if (success) {
                        response.sendRedirect("AdminEditRequestServlet?id=" + requestId + "&msg=assigned");
                    } else {
                        response.sendRedirect("AdminEditRequestServlet?id=" + requestId + "&msg=error");
                    }
                }
            } else if ("cancel".equals(action)) {
                // ... (Your existing cancel logic remains the same) ...
                 boolean success = dao.updateStatus(requestId, "Cancelled");
                if (success) {
                     response.sendRedirect("AdminEditRequestServlet?id=" + requestId + "&msg=cancelled");
                }
            } else {
                response.sendRedirect("AdminEditRequestServlet?id=" + requestId);
            }

        } catch (NumberFormatException e) {
            response.sendRedirect("AllRequestsServlet");
        }
    }
}