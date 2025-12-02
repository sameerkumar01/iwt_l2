<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit" %>
<%
    // 1. Retrieve parameters from the previous page
    String roomId = request.getParameter("room_id");
    String checkin = request.getParameter("checkin");
    String checkout = request.getParameter("checkout");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    
    // Default values
    double totalAmount = 0;
    String hotelName = "Booking Hotel";
    long nights = 0;
    String message = "";

    // Parse amount safely
    try {
        totalAmount = Double.parseDouble(request.getParameter("total_amount"));
    } catch (Exception e) {}

    // Get the logged-in user's username from the session
    String sessionUser = (String) session.getAttribute("user");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");

        // ---------------------------------------------------------
        // STEP 1: Get the User ID based on the session username
        // ---------------------------------------------------------
        int userId = -1;
        PreparedStatement psUser = con.prepareStatement("SELECT id FROM users WHERE username = ?");
        psUser.setString(1, sessionUser);
        ResultSet rsUser = psUser.executeQuery();
        
        if (rsUser.next()) {
            userId = rsUser.getInt("id");
        }

        // ---------------------------------------------------------
        // STEP 2: Insert the Booking into the Database
        // ---------------------------------------------------------
        if (userId != -1) {
            PreparedStatement psInsert = con.prepareStatement(
                "INSERT INTO bookings (user_id, room_id, check_in, check_out, name, email, status) VALUES (?, ?, ?, ?, ?, ?, 'confirmed')");
            psInsert.setInt(1, userId);
            psInsert.setInt(2, Integer.parseInt(roomId));
            psInsert.setString(3, checkin);
            psInsert.setString(4, checkout);
            psInsert.setString(5, name);
            psInsert.setString(6, email);
            
            int rowsAffected = psInsert.executeUpdate();

            // ---------------------------------------------------------
            // STEP 3: Mark the Room as 'Booked' (Unavailable)
            // ---------------------------------------------------------
            if (rowsAffected > 0) {
                PreparedStatement psUpdate = con.prepareStatement("UPDATE rooms SET available = 0 WHERE id = ?");
                psUpdate.setInt(1, Integer.parseInt(roomId));
                psUpdate.executeUpdate();
            }
        }

        // ---------------------------------------------------------
        // STEP 4: Fetch Hotel Name for Display
        // ---------------------------------------------------------
        PreparedStatement psHotel = con.prepareStatement(
            "SELECT h.name FROM rooms r JOIN hotels h ON r.hotel_id = h.id WHERE r.id = ?");
        psHotel.setInt(1, Integer.parseInt(roomId));
        ResultSet rsHotel = psHotel.executeQuery();
        if (rsHotel.next()) {
            hotelName = rsHotel.getString("name");
        }

        // Calculate nights for display
        LocalDate checkInDate = LocalDate.parse(checkin);
        LocalDate checkOutDate = LocalDate.parse(checkout);
        nights = ChronoUnit.DAYS.between(checkInDate, checkOutDate);

        con.close();
    } catch (Exception e) {
        // Log error to console for debugging
        System.out.println("Error in success.jsp: " + e.getMessage());
        message = "Error saving booking: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmed • Booking</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box;}
        body{
            font-family:'Inter',sans-serif;
            background:#f5f7fa;
            color:#1a1f36;
            display:flex;
            align-items:center;
            justify-content:center;
            min-height:100vh;
        }
        .container{
            max-width:420px;
            width:100%;
            background:white;
            border-radius:20px;
            box-shadow:0 25px 70px rgba(0,0,0,0.15);
            overflow:hidden;
            margin:20px;
        }
        .header{
            background:linear-gradient(135deg,#7c3aed,#3b82f6);
            padding:50px 30px;
            text-align:center;
            color:white;
        }
        .checkmark{
            width:90px;
            height:90px;
            border-radius:50%;
            background:#10b981;
            display:inline-block;
            position:relative;
            margin-bottom:20px;
        }
        .checkmark::after{
            content:'';
            position:absolute;
            top:25px;
            left:35px;
            width:25px;
            height:50px;
            border:solid white;
            border-width:0 8px 8px 0;
            transform:rotate(45deg);
        }
        .header h1{font-size:32px;font-weight:700;margin-bottom:8px;}
        .header p{font-size:17px;opacity:0.95;}

        .content{padding:40px 30px;text-align:center;}
        .hotel-name{font-size:26px;font-weight:700;color:#6d28d9;margin:15px 0;}
        .details{
            background:#f8f9ff;
            padding:25px;
            border-radius:16px;
            margin:25px 0;
            border:1px solid #e2e8f0;
        }
        .detail-row{
            display:flex;
            justify-content:space-between;
            margin:14px 0;
            font-size:16px;
        }
        .detail-row span:first-child{color:#64748b;}
        .detail-row span:last-child{font-weight:600;color:#1a1f36;}
        .total{font-size:22px !important;font-weight:700 !important;color:#6d28d9 !important;margin-top:10px;}

        .btn-group{margin-top:30px;}
        .btn{
            display:inline-block;
            padding:14px 28px;
            background:#6d28d9;
            color:white;
            border-radius:12px;
            text-decoration:none;
            font-weight:600;
            margin:0 10px;
            transition:0.3s;
            box-shadow:0 8px 20px rgba(109,40,217,0.3);
        }
        .btn:hover{
            background:#5b21b6;
            transform:translateY(-3px);
        }
        .footer{
            text-align:center;
            margin-top:40px;
            color:#94a3b8;
            font-size:14px;
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <div class="checkmark"></div>
        <h1>Booking Confirmed!</h1>
        <p>Congratulations <%= name %>! Your stay is booked.</p>
    </div>

    <div class="content">
        <div class="hotel-name"><%= hotelName %></div>
        <p style="color:#64748b;margin:10px 0 25px;">
            <%= nights %> night<%= nights>1?"s":"" %> • <%= checkin %> to <%= checkout %>
        </p>

        <div class="details">
            <div class="detail-row"><span>Guest Name</span><span><%= name %></span></div>
            <div class="detail-row"><span>Email</span><span><%= email %></span></div>
            <div class="detail-row"><span>Check-in</span><span><%= checkin %></span></div>
            <div class="detail-row"><span>Check-out</span><span><%= checkout %></span></div>
            <div class="detail-row total">
                <span>Amount Paid</span>
                <span>₹<%= String.format("%.0f", totalAmount) %></span>
            </div>
        </div>
        
        <% if(!message.isEmpty()) { %>
            <p style="color: red; font-size: 12px;"><%= message %></p>
        <% } %>

        <div class="btn-group">
            <a href="index.jsp" class="btn">Back to Home</a>
            <br><br>
            <a href="myBookings.jsp" class="btn">View My Bookings</a>
        </div>

        <div class="footer">
            <p>You will receive a confirmation email at <b><%= email %></b></p>
        </div>
    </div>
</div>

</body>
</html>