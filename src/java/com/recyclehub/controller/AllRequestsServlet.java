package com.recyclehub.controller;

import com.recyclehub.dao.PickupRequestDAO;
import com.recyclehub.dao.CollectorDAO;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.Collector;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AllRequestsServlet")
public class AllRequestsServlet extends HttpServlet {
    private PickupRequestDAO pickupRequestDAO = new PickupRequestDAO();
    private CollectorDAO collectorDAO = new CollectorDAO(); // You need this DAO

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
        throws ServletException, IOException {
    
        // Initialize DAOs
        PickupRequestDAO pickupRequestDAO = new PickupRequestDAO();
        CollectorDAO collectorDAO = new CollectorDAO();

        // 1. Get ALL requests from database (Since this method is known to work)
        List<PickupRequest> allRequests = pickupRequestDAO.getAllRequestsForAdmin();

        // 2. Prepare the list that will be sent to the JSP
        List<PickupRequest> filteredRequests = new java.util.ArrayList<>();

        // 3. Get the current tab
        String tab = request.getParameter("tab");
        if (tab == null) tab = "all"; // Default

        // 4. Filter logic in Java (Safe & Easy)
        if ("all".equalsIgnoreCase(tab)) {
            filteredRequests = allRequests;

        } else {
            // Loop through all requests and pick the ones we want
            for (PickupRequest p : allRequests) {
                String status = (p.getStatus() != null) ? p.getStatus() : "";

                if ("pending".equalsIgnoreCase(tab)) {
                    if ("Pending".equalsIgnoreCase(status)) {
                        filteredRequests.add(p);
                    }
                } 
                else if ("scheduled".equalsIgnoreCase(tab)) {
                    // Check for BOTH "Assigned" and "Scheduled"
                    if ("Assigned".equalsIgnoreCase(status) || "Scheduled".equalsIgnoreCase(status)) {
                        filteredRequests.add(p);
                    }
                } 
                else if ("completed".equalsIgnoreCase(tab)) {
                    if ("Completed".equalsIgnoreCase(status)) {
                        filteredRequests.add(p);
                    }
                }
            }
        }
        // Set attributes for the JSP
        request.setAttribute("pickupRequests", filteredRequests);
        request.setAttribute("collectorList", collectorDAO.getAllCollectors());
        request.setAttribute("currentTab", tab); // Send the current tab back to JSP to highlight the button

        // --- FIX: Use the correct filename "allRequest.jsp" (Singular) ---
        request.getRequestDispatcher("allRequest.jsp").forward(request, response);
    }
}