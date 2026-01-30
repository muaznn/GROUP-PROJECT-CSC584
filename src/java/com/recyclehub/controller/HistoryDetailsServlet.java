package com.recyclehub.controller;

import com.recyclehub.dao.PickupDetailsDAO;
import com.recyclehub.model.PickupDetails;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "HistoryDetailsServlet", urlPatterns = {"/HistoryDetailsServlet"})
public class HistoryDetailsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get the Request ID from the link (URL)
        String idStr = request.getParameter("id");
        
        // Security check: Did the URL have an ID?
        if (idStr == null || idStr.isEmpty()) {
            response.sendRedirect("PickupHistoryServlet"); // Go back if broken
            return;
        }
        
        int requestId = Integer.parseInt(idStr);

        // 2. Get the specific items for THIS request
        PickupDetailsDAO dao = new PickupDetailsDAO();
        List<PickupDetails> details = dao.getDetailsByRequestId(requestId);
        
        // 3. Send data to the Details JSP
        request.setAttribute("detailsList", details);
        request.setAttribute("requestId", requestId); // Send ID so we can display "Request #101"
        
        request.getRequestDispatcher("historyDetails.jsp").forward(request, response);
    }
}