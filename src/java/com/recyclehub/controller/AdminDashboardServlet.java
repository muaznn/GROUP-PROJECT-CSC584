package com.recyclehub.controller;

import com.recyclehub.dao.AdminDAO;
import com.recyclehub.model.PickupRequest;
import com.recyclehub.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/AdminDashboardServlet"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Security Check (Admin Only)
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Fetch Data
        AdminDAO dao = new AdminDAO();
        int totalReq = dao.getTotalRequestsCount();
        int pendingReq = dao.getPendingRequestsCount();
        int activeCollectors = dao.getActiveCollectorsCount();
        double monthlyWeight = dao.getMonthlyRecycledWeight();
        List<PickupRequest> recentList = dao.getRecentRequests();

        // 3. Set Attributes
        request.setAttribute("totalReq", totalReq);
        request.setAttribute("pendingReq", pendingReq);
        request.setAttribute("activeCollectors", activeCollectors);
        request.setAttribute("monthlyWeight", String.format("%.1f", monthlyWeight)); // Format to 1 decimal
        request.setAttribute("recentList", recentList);

        // 4. Forward to JSP
        request.getRequestDispatcher("adminDashboard.jsp").forward(request, response);
    }
}