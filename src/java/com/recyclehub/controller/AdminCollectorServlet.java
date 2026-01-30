package com.recyclehub.controller;

import com.recyclehub.dao.CollectorDAO;
import com.recyclehub.model.Collector;
import com.recyclehub.model.User;
import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "AdminCollectorServlet", urlPatterns = {"/AdminCollectorServlet"})
public class AdminCollectorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== DEBUG: AdminCollectorServlet.doGet() START ===");
        
        // Security Check
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            System.out.println("DEBUG: User not authenticated or not admin");
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("DEBUG: Action parameter = " + action);
        
        CollectorDAO collectorDAO = new CollectorDAO();
        
        try {
            if ("view".equals(action)) {
                // View single collector
                viewCollector(request, response, collectorDAO);
            } else if ("edit".equals(action)) {
                // Edit collector form
                editCollectorForm(request, response, collectorDAO);
            } else if ("add".equals(action)) {
                // Add collector form
                addCollectorForm(request, response);
            } else {
                // Default: List all collectors
                listCollectors(request, response, collectorDAO);
            }
            
        } catch (Exception e) {
            System.err.println("ERROR in AdminCollectorServlet.doGet: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error loading collectors: " + e.getMessage());
            listCollectors(request, response, collectorDAO);
        }
        
        System.out.println("=== DEBUG: AdminCollectorServlet.doGet() END ===");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("=== DEBUG: AdminCollectorServlet.doPost() START ===");
        
        // Security Check
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        System.out.println("DEBUG: POST Action = " + action);
        
        CollectorDAO collectorDAO = new CollectorDAO();
        
        try {
            if ("add".equals(action)) {
                // Add new collector
                addCollector(request, response, collectorDAO, session);
            } else if ("update".equals(action)) {
                // Update existing collector
                updateCollector(request, response, collectorDAO, session);
            } else if ("delete".equals(action)) {
                // Delete collector
                deleteCollector(request, response, collectorDAO, session);
            } else if ("toggle".equals(action)) {
                // Toggle collector status
                toggleStatus(request, response, collectorDAO, session);
            } else {
                // Default: redirect to list
                response.sendRedirect("AdminCollectorServlet");
            }
            
        } catch (Exception e) {
            System.err.println("ERROR in AdminCollectorServlet.doPost: " + e.getMessage());
            e.printStackTrace();
            session.setAttribute("errorMessage", "Error processing request: " + e.getMessage());
            response.sendRedirect("AdminCollectorServlet");
        }
        
        System.out.println("=== DEBUG: AdminCollectorServlet.doPost() END ===");
    }
    
    // ========== GET METHODS ==========
    
        private void listCollectors(HttpServletRequest request, HttpServletResponse response, 
                       CollectorDAO collectorDAO) throws ServletException, IOException {
    
            System.out.println("DEBUG: Listing all collectors");
            List<Collector> collectors = collectorDAO.getAllCollectors();

            if (collectors == null) {
                collectors = new ArrayList<Collector>();
            }

            // Set deletable status for each collector
            for (Collector collector : collectors) {
                boolean isDeletable = collectorDAO.isCollectorDeletable(collector.getCollectorId());
                collector.setDeletable(isDeletable);
                System.out.println("DEBUG: Collector ID " + collector.getCollectorId() + 
                                 " deletable: " + isDeletable);
            }

            request.setAttribute("collectors", collectors);
            request.getRequestDispatcher("collectors.jsp").forward(request, response);
        }

        private void viewCollector(HttpServletRequest request, HttpServletResponse response,
                                  CollectorDAO collectorDAO) throws ServletException, IOException {

            String idStr = request.getParameter("id");
            System.out.println("DEBUG: View collector with ID = " + idStr);

            if (idStr == null || idStr.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Collector ID is required");
                listCollectors(request, response, collectorDAO);
                return;
            }

            try {
                int collectorId = Integer.parseInt(idStr);
                Collector collector = collectorDAO.getCollectorById(collectorId);

                if (collector == null) {
                    request.setAttribute("errorMessage", "Collector not found with ID: " + collectorId);
                    listCollectors(request, response, collectorDAO);
                } else {
                    request.setAttribute("collector", collector);
                    request.getRequestDispatcher("viewCollector.jsp").forward(request, response);
                }

            } catch (NumberFormatException e) {
                request.setAttribute("errorMessage", "Invalid collector ID format");
                listCollectors(request, response, collectorDAO);
            }
        }
    
    private void editCollectorForm(HttpServletRequest request, HttpServletResponse response,
                                  CollectorDAO collectorDAO) throws ServletException, IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("DEBUG: Edit collector form for ID = " + idStr);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Collector ID is required");
            listCollectors(request, response, collectorDAO);
            return;
        }
        
        try {
            int collectorId = Integer.parseInt(idStr);
            Collector collector = collectorDAO.getCollectorById(collectorId);
            
            if (collector == null) {
                request.setAttribute("errorMessage", "Collector not found with ID: " + collectorId);
                listCollectors(request, response, collectorDAO);
            } else {
                request.setAttribute("collector", collector);
                request.getRequestDispatcher("editCollector.jsp").forward(request, response);
            }
            
        } catch (NumberFormatException e) {
            request.setAttribute("errorMessage", "Invalid collector ID format");
            listCollectors(request, response, collectorDAO);
        }
    }
    
    private void addCollectorForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        System.out.println("DEBUG: Showing add collector form");
        request.getRequestDispatcher("addCollector.jsp").forward(request, response);
    }
    
    // ========== POST METHODS ==========
    
    private void addCollector(HttpServletRequest request, HttpServletResponse response,
                             CollectorDAO collectorDAO, HttpSession session) throws IOException {
        
        System.out.println("DEBUG: Adding new collector");
        
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String plateNumber = request.getParameter("plateNumber");
        String status = request.getParameter("status");
        
        System.out.println("DEBUG: Collector data - Name: " + name + ", Phone: " + phone + 
                         ", Plate: " + plateNumber + ", Status: " + status);
        
        // Validate required fields
        if (name == null || name.trim().isEmpty() || 
            phone == null || phone.trim().isEmpty()) {
            
            session.setAttribute("errorMessage", "Name and Phone are required fields");
            response.sendRedirect("AdminCollectorServlet?action=add");
            return;
        }
        
        Collector collector = new Collector();
        collector.setName(name.trim());
        collector.setPhone(phone.trim());
        collector.setPlateNumber(plateNumber != null ? plateNumber.trim() : "");
        collector.setStatus(status != null ? status.trim() : "Available");
        
        int collectorId = collectorDAO.addCollector(collector);
        
        if (collectorId > 0) {
            System.out.println("DEBUG: Collector added successfully with ID: " + collectorId);
            session.setAttribute("successMessage", "Collector '" + collector.getName() + "' added successfully!");
        } else {
            System.out.println("DEBUG: Failed to add collector");
            session.setAttribute("errorMessage", "Failed to add collector. Please try again.");
        }
        
        response.sendRedirect("AdminCollectorServlet");
    }
    
    private void updateCollector(HttpServletRequest request, HttpServletResponse response,
                                CollectorDAO collectorDAO, HttpSession session) throws IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("DEBUG: Updating collector ID = " + idStr);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Collector ID is required");
            response.sendRedirect("AdminCollectorServlet");
            return;
        }
        
        try {
            int collectorId = Integer.parseInt(idStr);
            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String plateNumber = request.getParameter("plateNumber");
            String status = request.getParameter("status");
            
            System.out.println("DEBUG: Update data - Name: " + name + ", Phone: " + phone + 
                             ", Plate: " + plateNumber + ", Status: " + status);
            
            // Validate required fields
            if (name == null || name.trim().isEmpty() || 
                phone == null || phone.trim().isEmpty()) {
                
                session.setAttribute("errorMessage", "Name and Phone are required fields");
                response.sendRedirect("AdminCollectorServlet?action=edit&id=" + collectorId);
                return;
            }
            
            Collector collector = new Collector();
            collector.setCollectorId(collectorId);
            collector.setName(name.trim());
            collector.setPhone(phone.trim());
            collector.setPlateNumber(plateNumber != null ? plateNumber.trim() : "");
            collector.setStatus(status != null ? status.trim() : "Available");
            
            boolean success = collectorDAO.updateCollector(collector);
            
            if (success) {
                System.out.println("DEBUG: Collector updated successfully");
                session.setAttribute("successMessage", "Collector '" + collector.getName() + "' updated successfully!");
            } else {
                System.out.println("DEBUG: Failed to update collector");
                session.setAttribute("errorMessage", "Failed to update collector. Please try again.");
            }
            
            response.sendRedirect("AdminCollectorServlet");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid collector ID format");
            response.sendRedirect("AdminCollectorServlet");
        }
    }
    
    private void deleteCollector(HttpServletRequest request, HttpServletResponse response,
                                CollectorDAO collectorDAO, HttpSession session) throws IOException {
        
        String idStr = request.getParameter("id");
        System.out.println("DEBUG: Deleting collector ID = " + idStr);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Collector ID is required");
            response.sendRedirect("AdminCollectorServlet");
            return;
        }
        
        try {
            int collectorId = Integer.parseInt(idStr);
            
            // Check if collector can be deleted
            if (!collectorDAO.isCollectorDeletable(collectorId)) {
                session.setAttribute("errorMessage", "Cannot delete collector. This collector has active assignments. Please reassign or complete the assignments first.");
                response.sendRedirect("AdminCollectorServlet");
                return;
            }
            
            // Get collector name for success message
            Collector collector = collectorDAO.getCollectorById(collectorId);
            String collectorName = collector != null ? collector.getName() : "Collector";
            
            boolean success = collectorDAO.deleteCollector(collectorId);
            
            if (success) {
                System.out.println("DEBUG: Collector deleted successfully");
                session.setAttribute("successMessage", "Collector '" + collectorName + "' deleted successfully!");
            } else {
                System.out.println("DEBUG: Failed to delete collector");
                session.setAttribute("errorMessage", "Failed to delete collector. Please try again.");
            }
            
            response.sendRedirect("AdminCollectorServlet");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid collector ID format");
            response.sendRedirect("AdminCollectorServlet");
        }
    }
    
    private void toggleStatus(HttpServletRequest request, HttpServletResponse response,
                             CollectorDAO collectorDAO, HttpSession session) throws IOException {
        
        String idStr = request.getParameter("id");
        String currentStatus = request.getParameter("status");
        
        System.out.println("DEBUG: Toggling status for collector ID = " + idStr + ", current status = " + currentStatus);
        
        if (idStr == null || idStr.trim().isEmpty()) {
            session.setAttribute("errorMessage", "Collector ID is required");
            response.sendRedirect("AdminCollectorServlet");
            return;
        }
        
        try {
            int collectorId = Integer.parseInt(idStr);
            String newStatus = "Available".equals(currentStatus) ? "Busy" : "Available";
            
            System.out.println("DEBUG: Changing status from " + currentStatus + " to " + newStatus);
            
            boolean success = collectorDAO.toggleStatus(collectorId, newStatus);
            
            if (success) {
                System.out.println("DEBUG: Status toggled successfully");
                session.setAttribute("successMessage", "Collector status updated to '" + newStatus + "'!");
            } else {
                System.out.println("DEBUG: Failed to toggle status");
                session.setAttribute("errorMessage", "Failed to update collector status.");
            }
            
            response.sendRedirect("AdminCollectorServlet");
            
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid collector ID format");
            response.sendRedirect("AdminCollectorServlet");
        }
    }
}