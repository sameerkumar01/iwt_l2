<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.net.URLEncoder" %>
<%
String roomId = request.getParameter("room_id");
String checkin = request.getParameter("checkin");
String checkout = request.getParameter("checkout");

// Force login + redirect back
if (session.getAttribute("user") == null) {
    String redirectUrl = "bookingForm.jsp?room_id=" + roomId + "&checkin=" + checkin + "&checkout=" + checkout;
    response.sendRedirect("login.jsp?redirect=" + URLEncoder.encode(redirectUrl, "UTF-8"));
    return;
}

// Fetch hotel & room details
String hotelName = "Unknown Hotel";
String roomType = "Unknown Room";
double pricePerNight = 0.0;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");
    PreparedStatement ps = con.prepareStatement(
        "SELECT h.name AS hotel_name, r.type, r.price FROM rooms r JOIN hotels h ON r.hotel_id = h.id WHERE r.id = ? AND r.available = 1");
    ps.setInt(1, Integer.parseInt(roomId));
    ResultSet rs = ps.executeQuery();
    if (rs.next()) {
        hotelName = rs.getString("hotel_name");
        roomType = rs.getString("type");
        pricePerNight = rs.getDouble("price");
    }
    con.close();
} catch (Exception e) {
    out.println("<p style='color:red'>Database Error: " + e.getMessage() + "</p>");
}

// FIXED: Renamed 'out' → 'checkOutDate' to avoid conflict
LocalDate checkInDate = LocalDate.parse(checkin);
LocalDate checkOutDate = LocalDate.parse(checkout);
long nights = ChronoUnit.DAYS.between(checkInDate, checkOutDate);
double totalAmount = pricePerNight * nights;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Complete Your Booking • Booking</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5f7fa;color:#333;}
        header{background:#003580;color:white;padding:20px 40px;display:flex;justify-content:space-between;align-items:center;}
        .logo{font-size:28px;font-weight:bold;}
        .user-info a{color:white;margin-left:25px;text-decoration:none;font-weight:500;}
        .user-info a:hover{text-decoration:underline;}
        .container{max-width:900px;margin:40px auto;padding:30px;background:white;border-radius:16px;
                  box-shadow:0 15px 40px rgba(0,0,0,0.1);}
        h1{text-align:center;color:#003580;font-size:32px;margin-bottom:10px;}
        .subtitle{text-align:center;color:#666;font-size:18px;margin-bottom:40px;}
        .booking-summary{background:#f8fdff;padding:25px;border-radius:12px;border-left:5px solid #feba02;margin-bottom:30px;}
        .summary-row{display:flex;justify-content:space-between;padding:12px 0;border-bottom:1px solid #eee;}
        .summary-row:last-child{border-bottom:none;font-weight:bold;font-size:18px;color:#003580;}
        .total-amount{color:#e74c3c;font-size:28px;}
        form{background:#fff;padding:30px;border-radius:12px;box-shadow:0 8px 25px rgba(0,0,0,0.08);}
        label{display:block;margin:15px 0 8px;font-weight:600;color:#333;}
        input[type="text"], input[type="email"]{
            width:100%;padding:14px;border:2px solid #ddd;border-radius:10px;font-size:16px;transition:0.3s;
        }
        input:focus{outline:none;border-color:#feba02;}
        .proceed-btn{
            width:100%;padding:18px;background:#feba02;color:#003580;border:none;border-radius:12px;
            font-size:20px;font-weight:bold;cursor:pointer;margin-top:30px;transition:0.3s;
        }
        .proceed-btn:hover{background:#e6a800;transform:scale(1.02);}
        .back-link{display:block;text-align:center;margin-top:20px;color:#003580;font-weight:500;}
    </style>
</head>
<body>

<header>
    <div class="logo">Booking</div>
    <div class="user-info">
        Welcome, <b><%= session.getAttribute("user") %></b>
        <a href="myBookings.jsp">My Bookings</a>
        <a href="logout.jsp">Logout</a>
    </div>
</header>

<div class="container">
    <h1>Complete Your Booking</h1>
    <p class="subtitle">You're just one step away from your perfect stay</p>

    <div class="booking-summary">
        <div class="summary-row"><span>Hotel</span><b><%= hotelName %></b></div>
        <div class="summary-row"><span>Room Type</span><b><%= roomType %></b></div>
        <div class="summary-row"><span>Check-in</span><%= checkin %></div>
        <div class="summary-row"><span>Check-out</span><%= checkout %></div>
        <div class="summary-row"><span>Nights</span><%= nights %> night<%= nights > 1 ? "s" : "" %></div>
        <div class="summary-row"><span>Price per night</span>₹<%= String.format("%.0f", pricePerNight) %></div>
        <div class="summary-row"><span>Total Amount</span><span class="total-amount">₹<%= String.format("%.0f", totalAmount) %></span></div>
    </div>

    <form action="payment.jsp" method="post">
        <input type="hidden" name="room_id" value="<%= roomId %>">
        <input type="hidden" name="checkin" value="<%= checkin %>">
        <input type="hidden" name="checkout" value="<%= checkout %>">
        <input type="hidden" name="total_amount" value="<%= totalAmount %>">

        <label>Full Name</label>
        <input type="text" name="name" value="<%= session.getAttribute("user") %>" required>

        <label>Email Address</label>
        <input type="email" name="email" required>

        <button type="submit" class="proceed-btn">Proceed to Payment</button>
    </form>

    <a href="hotelDetails.jsp?hotel_id=<%= request.getParameter("hotel_id") %>&checkin=<%= checkin %>&checkout=<%= checkout %>" 
       class="back-link">Back to Rooms</a>
</div>

</body>
</html>