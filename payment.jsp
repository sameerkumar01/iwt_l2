<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit" %>
<%
    String roomId = request.getParameter("room_id");
    String checkin = request.getParameter("checkin");
    String checkout = request.getParameter("checkout");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    double totalAmount = Double.parseDouble(request.getParameter("total_amount"));

    // --- Fetch Hotel Name ---
    String hotelName = "LuxStay Hotel";
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
        PreparedStatement ps = con.prepareStatement(
            "SELECT h.name FROM rooms r JOIN hotels h ON r.hotel_id = h.id WHERE r.id = ?");
        ps.setInt(1, Integer.parseInt(roomId));
        ResultSet rs = ps.executeQuery();
        if (rs.next()) hotelName = rs.getString("name");
        con.close();
    } catch (Exception e) {
        hotelName = "LuxStay Hotel";
    }

    // --- Calculate nights (NEVER use variable name "out" in JSP!) ---
    LocalDate checkInDate = LocalDate.parse(checkin);
    LocalDate checkOutDate = LocalDate.parse(checkout);   // Fixed: renamed from "out"
    long nights = ChronoUnit.DAYS.between(checkInDate, checkOutDate);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pay ₹<%= String.format("%.0f", totalAmount) %> • Razorpay</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{font-family:'Inter',sans-serif;background:#f5f7fa;color:#1a1f36;}
        .container{max-width:420px;margin:40px auto;background:white;border-radius:16px;
                  box-shadow:0 20px 60px rgba(0,0,0,0.12);overflow:hidden;}
        .header{background:#6d28d9;padding:24px;text-align:center;color:white;position:relative;}
        .header::before{
            content:'';position:absolute;top:0;left:0;right:0;bottom:0;
            background:linear-gradient(135deg,#7c3aed,#3b82f6);opacity:0.9;
        }
        .header h1{font-size:28px;font-weight:700;position:relative;z-index:1;}
        .header p{font-size:16px;opacity:0.9;margin-top:6px;position:relative;z-index:1;}
        
        .content{padding:30px;}
        .hotel-name{font-size:24px;font-weight:700;color:#1a1f36;margin-bottom:8px;}
        .booking-details{background:#f8f9ff;padding:20px;border-radius:12px;margin:20px 0;
                         border:1px solid #e2e8f0;}
        .detail-row{display:flex;justify-content:space-between;margin:12px 0;font-size:15px;}
        .detail-row span:first-child{color:#64748b;}
        .detail-row span:last-child{font-weight:600;color:#1a1f36;}
        .total-row{font-size:20px !important;font-weight:700 !important;color:#6d28d9 !important;}
        
        .payment-form{margin-top:30px;}
        .input-group{margin-bottom:20px;}
        label{display:block;font-size:14px;font-weight:600;color:#374151;margin-bottom:8px;}
        input[type="text"], input[type="email"]{
            width:100%;padding:14px 16px;border:2px solid #e2e8f0;border-radius:10px;
            font-size:16px;transition:0.3s;background:#fcfdff;
        }
        input:focus{outline:none;border-color:#6d28d9;box-shadow:0 0 0 4px rgba(109,40,217,0.1);}
        
        .pay-btn{
            width:100%;padding:18px;background:#6d28d9;color:white;border:none;
            border-radius:12px;font-size:18px;font-weight:700;cursor:pointer;
            margin-top:20px;transition:0.3s;box-shadow:0 8px 25px rgba(109,40,217,0.3);
        }
        .pay-btn:hover{background:#5b21b6;transform:translateY(-2px);}
        .pay-btn:active{transform:translateY(0);}
        
        .secure{text-align:center;margin-top:20px;color:#64748b;font-size:13px;}
        .secure img{height:20px;margin-right:8px;vertical-align:middle;}
        .razorpay-logo{text-align:center;margin:20px 0 10px;}
        .razorpay-logo img{height:32px;}
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <h1>Complete Payment</h1>
        <p>Secure checkout powered by Razorpay</p>
    </div>

    <div class="content">
        <!-- Hotel Name on Top -->
        <div class="hotel-name"><%= hotelName %></div>
        <div style="color:#64748b;font-size:14px;margin-bottom:20px;">
            <%= nights %> night<%= nights > 1 ? "s" : "" %> • <%= checkin %> to <%= checkout %>
        </div>

        <div class="booking-details">
            <div class="detail-row"><span>Guest Name</span><span><%= name %></span></div>
            <div class="detail-row"><span>Email</span><span><%= email %></span></div>
            <div class="detail-row"><span>Nights</span><span><%= nights %></span></div>
            <div class="detail-row total-row">
                <span>Total Amount</span>
                <span>₹<%= String.format("%.0f", totalAmount) %></span>
            </div>
        </div>

        <form action="success.jsp" method="post" class="payment-form">
            <input type="hidden" name="room_id" value="<%= roomId %>">
            <input type="hidden" name="checkin" value="<%= checkin %>">
            <input type="hidden" name="checkout" value="<%= checkout %>">
            <input type="hidden" name="name" value="<%= name %>">
            <input type="hidden" name="email" value="<%= email %>">
            <input type="hidden" name="total_amount" value="<%= totalAmount %>">

            <div class="input-group">
                <label>Card Number</label>
                <input type="text" placeholder="1234 5678 9012 3456" maxlength="19" required>
            </div>
            <div style="display:flex;gap:12px;">
                <div class="input-group" style="flex:1;">
                    <label>Expiry Date</label>
                    <input type="text" placeholder="MM/YY" maxlength="5" required>
                </div>
                <div class="input-group" style="flex:1;">
                    <label>CVV</label>
                    <input type="text" placeholder="123" maxlength="3" required>
                </div>
            </div>

            <button type="submit" class="pay-btn">
                Pay ₹<%= String.format("%.0f", totalAmount) %>
            </button>
        </form>
        <br>
        <p>Your payment info is encrypted and secure</p>
    </div>
</div>

</body>
</html>