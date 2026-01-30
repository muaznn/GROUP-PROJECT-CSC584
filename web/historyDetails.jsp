<%@page import="java.util.List"%>
<%@page import="com.recyclehub.model.PickupDetails"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
    <title>Pickup Details</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

    <div class="header" style="background: #2c3e50; padding: 15px; color: white;">
        <a href="PickupHistoryServlet" style="color: white; text-decoration: none;">&larr; Back to History</a>
    </div>

    <div class="container" style="padding: 20px; max-width: 600px; margin: 0 auto;">
        
        <div class="card" style="background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
            
            <h2 style="border-bottom: 2px solid #eee; padding-bottom: 10px;">
                Request #<%= request.getAttribute("requestId") %> Details
            </h2>

            <table style="width: 100%; margin-top: 20px; border-collapse: collapse;">
                <thead style="background: #f8f9fa;">
                    <tr>
                        <th style="padding: 10px; text-align: left;">Waste Material</th>
                        <th style="padding: 10px; text-align: right;">Weight (kg)</th>
                        <th style="padding: 10px; text-align: right;">Remarks</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        List<PickupDetails> details = (List<PickupDetails>) request.getAttribute("detailsList");
                        double totalWeight = 0;

                        if (details != null) {
                            for (PickupDetails d : details) {
                                totalWeight += d.getWeight();
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; font-size: 1.1em;">
                            <%= d.getCategory() %>
                        </td>
                        <td style="padding: 12px; text-align: right; font-weight: bold;">
                            <%= d.getWeight() %> kg
                        </td>
                    </tr>
                    <% 
                            }
                        } 
                    %>
                    
                    <tr style="background-color: #e9ecef; font-weight: bold;">
                        <td style="padding: 15px;">TOTAL</td>
                        <td style="padding: 15px; text-align: right;"><%= totalWeight %> kg</td>
                    </tr>
                </tbody>
            </table>
            
            <br>
            <div style="text-align: center; margin-top: 20px;">
                <button onclick="window.print()" class="btn" style="background: #6c757d;">🖨️ Print Receipt</button>
            </div>

        </div>
    </div>

</body>
</html>