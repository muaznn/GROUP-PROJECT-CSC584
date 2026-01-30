package com.recyclehub.controller;

import com.recyclehub.dao.RewardsDAO;
import com.recyclehub.dao.RedemptionDAO;
import com.recyclehub.dao.UserDAO;
import com.recyclehub.model.User;
import com.recyclehub.model.Rewards;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "RewardServlet", urlPatterns = {"/RewardServlet"})
public class RewardServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        
        if ("redeem".equals(action)) {
            try {
                // Get parameters
                int rewardsId = Integer.parseInt(request.getParameter("rewardsId"));
                int pointsCost = Integer.parseInt(request.getParameter("pointsCost"));
                int userId = user.getUserId();
                
                // Initialize DAOs
                RedemptionDAO redemptionDAO = new RedemptionDAO();
                UserDAO userDAO = new UserDAO();
                
                // 1. Verify Points (Server-side validation)
                User currentUser = userDAO.getUserById(userId);
                if (currentUser.getCurrentPoints() < pointsCost) {
                    response.sendRedirect("rewards.jsp?redeemed=error&message=insufficient_points");
                    return;
                }
                
                // 2. REMOVED RESTRICTION: 
                // Commenting this out allows users to buy the same voucher multiple times.
                // If you really want them to only buy it ONCE ever, uncomment this.
                /*
                if (redemptionDAO.hasUserRedeemedReward(userId, rewardsId)) {
                    response.sendRedirect("rewards.jsp?redeemed=error&message=already_redeemed");
                    return;
                }
                */
                
                // 3. Process Transaction
                // Step A: Deduct Points
                boolean pointsDeducted = userDAO.deductPoints(userId, pointsCost);
                
                if (pointsDeducted) {
                    // Step B: Create Redemption Record
                    boolean redemptionCreated = redemptionDAO.createRedemption(userId, rewardsId);
                    
                    if (redemptionCreated) {
                        // Success! Update session user to reflect new points immediately for UI
                        currentUser.setCurrentPoints(currentUser.getCurrentPoints() - pointsCost);
                        session.setAttribute("user", currentUser);
                        
                        response.sendRedirect("rewards.jsp?redeemed=success");
                    } else {
                        // CRITICAL: Rollback points if redemption insert failed
                        userDAO.addPoints(userId, pointsCost);
                        System.out.println("Error: Points deducted but Redemption Insert failed. Rolled back points.");
                        response.sendRedirect("rewards.jsp?redeemed=error&message=db_insert_failed");
                    }
                } else {
                    response.sendRedirect("rewards.jsp?redeemed=error&message=points_deduction_failed");
                }
                
            } catch (Exception e) {
                // Log the actual error to your server console so you can see it
                e.printStackTrace(); 
                response.sendRedirect("rewards.jsp?redeemed=error&message=system_error");
            }
        }
    }
}