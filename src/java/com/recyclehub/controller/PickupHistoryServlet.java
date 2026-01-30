package com.recyclehub.controller;

import com.recyclehub.dao.PickupRequestDAO;
import com.recyclehub.dao.PickupDetailsDAO;
import com.recyclehub.model.User;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.PickupDetails;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "PickupHistoryServlet", urlPatterns = {"/PickupHistoryServlet"})
public class PickupHistoryServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int userId = user.getUserId();
        
        // Get pickup requests for this user
        PickupRequestDAO pickupRequestDAO = new PickupRequestDAO();
        List<PickupRequest> pickupHistory = pickupRequestDAO.getRequestsByUserId(userId);
        
        // Get pickup details for all requests
        PickupDetailsDAO pickupDetailsDAO = new PickupDetailsDAO();
        List<PickupDetails> allDetails = null;
        if (pickupHistory != null && !pickupHistory.isEmpty()) {
            allDetails = pickupDetailsDAO.getAllDetailsForUser(userId);
        }
        
        // Set attributes for JSP
        request.setAttribute("historyList", pickupHistory);
        request.setAttribute("pickupDetailsList", allDetails);
        
        // Forward to JSP
        request.getRequestDispatcher("pickupHistory.jsp").forward(request, response);
    }
}