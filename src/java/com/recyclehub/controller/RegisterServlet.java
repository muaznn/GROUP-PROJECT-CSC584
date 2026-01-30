package com.recyclehub.controller;

import com.recyclehub.dao.UserDAO;
import com.recyclehub.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/RegisterServlet"})
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Retrieve data from the JSP form
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address"); // Make sure your HTML has this field!

        // 2. Wrap the data in a User Bean
        User newUser = new User();
        newUser.setName(name);
        newUser.setEmail(email);
        newUser.setPassword(password);
        newUser.setPhone(phone);
        newUser.setAddress(address);
        // Role and Points are set by default in the DAO/Database

        // 3. Call the DAO to save it
        UserDAO dao = new UserDAO();
        boolean success = dao.registerUser(newUser);

        if (success) {
            // SUCCESS: Send them to Login page with a success message
            // We use a small URL parameter ?registered=true to trigger a popup
            response.sendRedirect("login.jsp?registered=true");
        } else {
            // FAILURE: Stay on Register page, show error
            request.setAttribute("errorMessage", "Registration failed. Email might already exist.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}