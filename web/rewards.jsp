<%@page import="com.recyclehub.model.User"%>
<%@page import="com.recyclehub.model.Rewards"%>
<%@page import="com.recyclehub.model.Redemption"%>
<%@page import="com.recyclehub.dao.RewardsDAO"%>
<%@page import="com.recyclehub.dao.RedemptionDAO"%>
<%@page import="com.recyclehub.dao.UserDAO"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Check if user is logged in
    User user = (User) session.getAttribute("user");
    if (user == null || !"user".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Initialize DAOs
    RewardsDAO rewardsDAO = new RewardsDAO();
    RedemptionDAO redemptionDAO = new RedemptionDAO();
    UserDAO userDAO = new UserDAO();
    
    // Get user's current points from database
    User currentUser = userDAO.getUserById(user.getUserId());
    int userPoints = currentUser.getCurrentPoints();
    
    // Get available rewards from database
    List<Rewards> availableRewards = rewardsDAO.getAllActiveRewards();
    
    // Get user's redemptions from database
    List<Redemption> userRedemptions = redemptionDAO.getRedemptionsByUserId(user.getUserId());
    
    // Determine user rank based on points
    String userRank = "Bronze";
    String rankColor = "#cd7f32";
    int pointsToNextRank = 0;
    
    if (userPoints >= 5000) {
        userRank = "Platinum";
        rankColor = "#e5e4e2";
        pointsToNextRank = 0;
    } else if (userPoints >= 2500) {
        userRank = "Gold";
        rankColor = "#ffd700";
        pointsToNextRank = 5000 - userPoints;
    } else if (userPoints >= 1000) {
        userRank = "Silver";
        rankColor = "#c0c0c0";
        pointsToNextRank = 2500 - userPoints;
    } else {
        pointsToNextRank = 1000 - userPoints;
    }
    
    // Calculate progress percentage
    int progressPercentage = 0;
    if (userPoints >= 5000) {
        progressPercentage = 100;
    } else if (userPoints >= 2500) {
        progressPercentage = 75;
    } else if (userPoints >= 1000) {
        progressPercentage = 50;
    } else if (userPoints >= 0) {
        progressPercentage = (int)((userPoints / 1000.0) * 50);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RecycleHub - Eco Rewards</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <div class="container header-content">
            <a href="DashboardServlet" class="logo">
                <span>♻️</span>
                <span>RecycleHub</span>
            </a>
            <nav>
                <ul>
                    <li><a href="DashboardServlet">Dashboard</a></li>
                    <li><a href="requestPickup.jsp">Request Pickup</a></li>
                    <li><a href="rewards.jsp" class="active">Rewards</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                </ul>
            </nav>
            <div class="user-menu">
                <span id="user-display"><%= currentUser.getName() %></span>
                <span class="user-role">User</span>
                <a href="LogoutServlet" class="btn btn-danger" onclick="return confirm('Are you sure you want to logout?')">Logout</a>
            </div>
        </div>
    </header>

    <main class="container">
        <div class="page-container active">
            <h1 class="page-title">♻️ Eco Rewards</h1>
            
            <div class="card">
                <!-- Header Section: The "Bank" -->
                <!-- Header Section: The "Bank" -->
                <div style="background: linear-gradient(135deg, #ff9800, #ff5722); color: white; padding: 25px; border-radius: 8px; margin-bottom: 25px;">
                    <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; margin-bottom: 20px;">
                        <div>
                            <h2 style="font-size: 28px; margin-bottom: 5px;">Your Eco Points</h2>
                            <div style="font-size: 48px; font-weight: 700; margin: 10px 0;" id="current-points-balance"><%= userPoints %></div>
                            <p style="opacity: 0.9; font-size: 14px;">Available for redemption</p>
                        </div>
                        <div style="text-align: right;">
                            <div style="background: rgba(255,255,255,0.2); padding: 10px 20px; border-radius: 20px; display: inline-block;">
                                <div style="font-size: 14px; opacity: 0.9;">Current Rank</div>
                                <div style="font-size: 24px; font-weight: 700; color: <%= rankColor %>" id="user-rank"><%= userRank %></div>
                            </div>
                            <div style="margin-top: 10px; font-size: 14px;">
                                <span id="next-rank-points"><%= pointsToNextRank > 0 ? pointsToNextRank : 0 %></span> points to next rank
                            </div>
                        </div>
                    </div>

                    <!-- Progress Bar -->
                    <div style="margin-top: 20px;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 5px;">
                            <span>Bronze</span>
                            <span>Silver</span>
                            <span>Gold</span>
                            <span>Platinum</span>
                        </div>
                        <div style="background: rgba(255,255,255,0.3); height: 10px; border-radius: 5px; overflow: hidden;">
                            <div id="rank-progress" style="background: white; height: 100%; width: <%= progressPercentage %>%; transition: width 0.5s;"></div>
                        </div>
                    </div>
                </div>
                
                <!-- Tabs for Marketplace and My Rewards -->
                <div class="tabs">
                    <button class="tab active" onclick="switchRewardTab('marketplace')">Marketplace</button>
                    <button class="tab" onclick="switchRewardTab('my-rewards')">My Rewards</button>
                </div>
                
                <!-- Marketplace Tab -->
                <div class="tab-content active" id="marketplace-tab">
                    <h3 class="section-title">Available Rewards</h3>
                    <p class="section-description">
                        Redeem your Eco Points for exciting rewards from our local partners!
                    </p>
                    
                    <div class="rewards-grid" id="rewards-grid">
                        <% 
                        if (availableRewards != null && !availableRewards.isEmpty()) {
                            for (Rewards reward : availableRewards) {
                                boolean canAfford = userPoints >= reward.getPointCost();
                                String emoji = getRewardEmoji(reward.getRewardName());
                                String partnerName = extractPartnerName(reward.getRewardName());
                        %>
                        <div class="reward-card <%= canAfford ? "" : "disabled" %>" 
                             data-rewards-id="<%= reward.getCatalogId() %>" 
                             data-rewards-name="<%= reward.getRewardName() %>" 
                             data-rewards-description="<%= reward.getDescription() %>"
                             data-points-cost="<%= reward.getPointCost() %>"
                             data-partner-name="<%= partnerName %>"
                             onclick="<% if (canAfford) { %>openRewardModal(this)<% } %>">
                            <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 15px;">
                                <div style="font-size: 24px;"><%= emoji %></div>
                                <div style="text-align: right;">
                                    <div style="font-size: 12px; color: #666;">Cost</div>
                                    <div style="font-size: 20px; font-weight: 700; color: <%= canAfford ? "#ff9800" : "#666" %>">
                                        <%= reward.getPointCost() %> pts
                                    </div>
                                </div>
                            </div>

                            <h4 style="margin-bottom: 10px; color: #28a745;"><%= reward.getRewardName() %></h4>
                            <p style="color: #666; font-size: 14px; margin-bottom: 15px;"><%= reward.getDescription() %></p>

                            <div style="display: flex; justify-content: space-between; align-items: center;">
                                <span style="font-size: 12px; color: #666;"><%= partnerName %></span>
                                <div style="font-size: 20px;">
                                    <%= canAfford ? "✓" : "🔒" %>
                                </div>
                            </div>
                        </div>
                        <% 
                            }
                        } else { 
                        %>
                        <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: #666;">
                            <div style="font-size: 48px; margin-bottom: 20px;">🎁</div>
                            <h3>No Rewards Available</h3>
                            <p>Check back later for new rewards!</p>
                        </div>
                        <% } %>
                    </div>
                </div>
                
                <!-- My Rewards Tab -->
                <div class="tab-content" id="my-rewards-tab">
                    <h3 class="section-title">My Redeemed Rewards</h3>
                    <p class="section-description">
                        Your redeemed rewards history.
                    </p>
                    
                    <div id="active-rewards-container">
                        <% if (userRedemptions == null || userRedemptions.isEmpty()) { %>
                        <div id="no-active-rewards" style="text-align: center; padding: 40px; color: #666; display: block;">
                            <div style="font-size: 48px; margin-bottom: 20px;">🎁</div>
                            <h3>No Redeemed Rewards</h3>
                            <p>You haven't redeemed any rewards yet.</p>
                            <button class="btn btn-primary" onclick="switchRewardTab('marketplace')" style="margin-top: 20px;">
                                Browse Marketplace
                            </button>
                        </div>
                        <% } else { %>
                        <div class="table-responsive">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Reward Name</th>
                                        <th>Points Cost</th>
                                        <th>Redeemed Date</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% 
                                    for (Redemption redemption : userRedemptions) {
                                        // Get reward details for each redemption
                                        Rewards reward = rewardsDAO.getRewardById(redemption.getCatalogId());
                                        if (reward != null) {
                                    %>
                                    <tr>
                                        <td><%= reward.getRewardName() %></td>
                                        <td><span class="points-badge"><%= reward.getPointCost() %> pts</span></td>
                                        <td><%= redemption.getRedeemDate() %></td>
                                        <td><span class="status-badge status-<%= redemption.getStatus().toLowerCase() %>"><%= redemption.getStatus() %></span></td>
                                    </tr>
                                    <% 
                                        }
                                    } 
                                    %>
                                </tbody>
                            </table>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <!-- Reward Redemption Modal -->
    <div id="reward-modal" class="modal-overlay">
        <div class="modal-content">
            <h2 id="modal-reward-title" class="modal-title"></h2>
            <p id="modal-reward-description" style="color: #666; margin-bottom: 25px;"></p>
            
            <div style="background: #e8f5e8; padding: 20px; border-radius: 8px; margin-bottom: 25px;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <div style="font-size: 14px; color: #666;">Your Points Balance</div>
                        <div style="font-size: 24px; font-weight: 700; color: #28a745;" id="modal-current-points"><%= userPoints %></div>
                    </div>
                    <div style="text-align: center;">
                        <div style="font-size: 14px; color: #666;">Required Points</div>
                        <div style="font-size: 24px; font-weight: 700; color: #ff9800;" id="modal-required-points">0</div>
                    </div>
                    <div style="text-align: right;">
                        <div style="font-size: 14px; color: #666;">Remaining After</div>
                        <div style="font-size: 24px; font-weight: 700; color: #218838;" id="modal-remaining-points">0</div>
                    </div>
                </div>
            </div>
            
            <div id="modal-error" class="alert alert-error" style="display: none; margin-bottom: 20px;"></div>
            
            <form id="redeem-form" method="POST" action="RewardServlet">
                <input type="hidden" name="action" value="redeem">
                <input type="hidden" id="modal-rewards-id" name="rewardsId">
                <input type="hidden" id="modal-rewards-name" name="rewardsName">
                <input type="hidden" id="modal-points-cost" name="pointsCost">
                <input type="hidden" id="modal-user-id" name="userId" value="<%= user.getUserId() %>">
                
                <div style="display: flex; gap: 15px; margin-top: 25px;">
                    <button type="submit" id="confirm-redeem-btn" class="btn btn-primary" style="flex: 1;">
                        ✅ Confirm Redeem
                    </button>
                    <button type="button" onclick="closeRewardModal()" class="btn" style="flex: 1;">
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    </div>

    <footer>
        <div class="container">
            <div class="footer-content">
                <div class="logo" style="font-size: 20px;">
                    <span>♻️</span>
                    <span>RecycleHub</span>
                </div>
                <div style="text-align: right;">
                    <p>Community Recycling Collection System</p>
                    <p>Helping communities recycle better</p>
                </div>
            </div>
            <div class="copyright">
                &copy; 2023 RecycleHub. All rights reserved.
            </div>
        </div>
    </footer>

    <script>
        let currentReward = null;

        function switchRewardTab(tabName) {
            // Update tabs
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Update tab content
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            
            // Activate clicked tab
            const tabs = document.querySelectorAll('.tab');
            if (tabName === 'marketplace') {
                tabs[0].classList.add('active');
                document.getElementById('marketplace-tab').classList.add('active');
            } else if (tabName === 'my-rewards') {
                tabs[1].classList.add('active');
                document.getElementById('my-rewards-tab').classList.add('active');
            }
        }

        function openRewardModal(rewardCard) {
            currentReward = {
                id: rewardCard.getAttribute('data-rewards-id'),
                name: rewardCard.getAttribute('data-rewards-name'),
                description: rewardCard.getAttribute('data-rewards-description'),
                points: parseInt(rewardCard.getAttribute('data-points-cost')),
                partner: rewardCard.getAttribute('data-partner-name')
            };
            
            const userPoints = <%= userPoints %>;
            const remainingPoints = userPoints - currentReward.points;
            
            document.getElementById('modal-reward-title').textContent = currentReward.name;
            document.getElementById('modal-reward-description').textContent = currentReward.description;
            document.getElementById('modal-current-points').textContent = userPoints;
            document.getElementById('modal-required-points').textContent = currentReward.points;
            document.getElementById('modal-remaining-points').textContent = remainingPoints;
            
            // Set form values
            document.getElementById('modal-rewards-id').value = currentReward.id;
            document.getElementById('modal-rewards-name').value = currentReward.name;
            document.getElementById('modal-points-cost').value = currentReward.points;
            
            // Clear any previous error
            document.getElementById('modal-error').style.display = 'none';
            
            // Show modal
            document.getElementById('reward-modal').style.display = 'flex';
        }

        function closeRewardModal() {
            document.getElementById('reward-modal').style.display = 'none';
            currentReward = null;
        }
        
        // Form submission handler
        document.getElementById('redeem-form').addEventListener('submit', function(e) {
            const userPoints = <%= userPoints %>;
            const requiredPoints = currentReward ? currentReward.points : 0;
            
            if (userPoints < requiredPoints) {
                e.preventDefault();
                document.getElementById('modal-error').textContent = 
                    `Insufficient points! You need ${requiredPoints - userPoints} more points.`;
                document.getElementById('modal-error').style.display = 'block';
                return false;
            }
            
            // Show loading state
            const submitBtn = document.getElementById('confirm-redeem-btn');
            const originalText = submitBtn.textContent;
            submitBtn.textContent = 'Processing...';
            submitBtn.disabled = true;
            
            // Allow form submission
            return true;
        });
        
        // Handle success message from servlet
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const redeemed = urlParams.get('redeemed');
            const message = urlParams.get('message'); // Capture specific error message

            if (redeemed === 'success') {
                alert('Reward redeemed successfully!');
                // Clean URL without refreshing
                window.history.replaceState({}, document.title, "rewards.jsp");
                // Reload to update table
                window.location.reload();
            } else if (redeemed === 'error') {
                let msg = 'Failed to redeem reward.';
                if(message === 'insufficient_points') msg += ' Not enough points.';
                if(message === 'already_redeemed') msg += ' You have already claimed this.';
                if(message === 'system_error') msg += ' System error occurred.';

                alert(msg);
                // Clean URL
                window.history.replaceState({}, document.title, "rewards.jsp");
            }
            
            // Add hover effects to reward cards
            document.querySelectorAll('.reward-card:not(.disabled)').forEach(card => {
                card.addEventListener('mouseenter', function() {
                    this.style.transform = 'translateY(-5px)';
                    this.style.boxShadow = '0 10px 20px rgba(0,0,0,0.1)';
                });
                card.addEventListener('mouseleave', function() {
                    this.style.transform = 'translateY(0)';
                    this.style.boxShadow = 'none';
                });
            });
        });
        
        // Close modals when clicking outside
        window.addEventListener('click', function(e) {
            if (e.target.id === 'reward-modal') {
                closeRewardModal();
            }
        });
        
        // Escape key to close modals
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeRewardModal();
            }
        });
    </script>
</body>
</html>

<%!
    // Helper method to extract partner name from reward name
    private String extractPartnerName(String rewardName) {
        if (rewardName == null) return "RecycleHub Partner";
        
        String name = rewardName.toLowerCase();
        if (name.contains("grab") || name.contains("food")) {
            return "GrabFood";
        } else if (name.contains("tesco")) {
            return "Tesco";
        } else if (name.contains("touch") || name.contains("tng")) {
            return "Touch n Go";
        } else if (name.contains("starbucks")) {
            return "Starbucks";
        } else if (name.contains("lotus")) {
            return "Lotus";
        } else if (name.contains("cinema") || name.contains("gsc")) {
            return "GSC Cinemas";
        } else if (name.contains("petronas")) {
            return "Petronas";
        } else if (name.contains("kfc")) {
            return "KFC";
        } else if (name.contains("recyclehub")) {
            return "RecycleHub";
        } else {
            return "Local Partner";
        }
    }
    
    // Helper method to get emoji for reward
    private String getRewardEmoji(String rewardName) {
        if (rewardName == null) return "🎁";
        
        String name = rewardName.toLowerCase();
        if (name.contains("food") || name.contains("grab") || name.contains("kfc") || name.contains("meal")) {
            return "🍔";
        } else if (name.contains("coffee") || name.contains("starbucks") || name.contains("drink")) {
            return "☕";
        } else if (name.contains("grocery") || name.contains("tesco") || name.contains("lotus") || name.contains("shopping")) {
            return "🛒";
        } else if (name.contains("ewallet") || name.contains("touch") || name.contains("reload") || name.contains("voucher")) {
            return "💳";
        } else if (name.contains("cinema") || name.contains("ticket") || name.contains("movie")) {
            return "🎬";
        } else if (name.contains("fuel") || name.contains("petronas")) {
            return "⛽";
        } else if (name.contains("bag") || name.contains("tote")) {
            return "👜";
        } else if (name.contains("bottle") || name.contains("water")) {
            return "💧";
        } else {
            return "🎁";
        }
    }
%>