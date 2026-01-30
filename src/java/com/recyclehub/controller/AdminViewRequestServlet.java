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

@WebServlet(name = "AdminViewRequestServlet", urlPatterns = {"/AdminViewRequestServlet"})
public class AdminViewRequestServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Same security check as AdminRequestDetailsServlet
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        String idStr = request.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            response.sendRedirect("AllRequestsServlet");
            return;
        }
        
        try {
            int requestId = Integer.parseInt(idStr);
            PickupRequestDAO requestDAO = new PickupRequestDAO();
            PickupDetailsDAO detailsDAO = new PickupDetailsDAO();

            PickupRequest req = requestDAO.getRequestByIds(requestId);
            if (req == null) {
                response.sendRedirect("AllRequestsServlet");
                return;
            }
            
            List<PickupDetails> details = detailsDAO.getDetailsByRequestId(requestId);
            
            request.setAttribute("request", req);
            request.setAttribute("detailsList", details);
            
            // Forward to VIEW-ONLY page
            request.getRequestDispatcher("adminViewRequest.jsp").forward(request, response);
            
        } catch (NumberFormatException e) {
            response.sendRedirect("AllRequestsServlet");
        }
    }
}