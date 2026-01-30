package com.recyclehub.controller;

import com.recyclehub.dao.UserDAO;
import com.recyclehub.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "ProfileServlet", urlPatterns = {"/ProfileServlet"})
public class ProfileServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get current user from session
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 2. Get new data from form
        String newName = request.getParameter("name");
        String newPhone = request.getParameter("phone");
        String newAddress = request.getParameter("address");

        // 3. Update the User Object (in memory)
        user.setName(newName);
        user.setPhone(newPhone);
        user.setAddress(newAddress);

        // 4. Update the Database
        UserDAO dao = new UserDAO();
        boolean success = dao.updateUser(user);

        // 5. Handle result
        if (success) {
            // CRITICAL: Update the session with the new info!
            session.setAttribute("user", user);
            
            request.setAttribute("message", "Profile updated successfully!");
            request.setAttribute("messageType", "success");
        } else {
            request.setAttribute("message", "Failed to update profile. Please try again.");
            request.setAttribute("messageType", "error");
        }
        
        // Send back to the profile page to show the message
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
}