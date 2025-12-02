<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hotel Details • Booking</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5f7fa; color:#333;}
        header{background:#003580;color:white;padding:20px 40px;display:flex;justify-content:space-between;align-items:center;}
        .logo{font-size:28px;font-weight:bold;}
        .user-info a{color:white;margin-left:25px;text-decoration:none;font-weight:500;}
        .user-info a:hover{text-decoration:underline;}
        .container{max-width:1300px;margin:40px auto;padding:0 20px;}
        .page-title{text-align:center;font-size:36px;color:#003580;margin:20px 0 10px;}
        .search-info{text-align:center;color:#666;font-size:18px;margin-bottom:40px;}
        .rooms-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:30px;}
        .room-card{background:white;border-radius:16px;overflow:hidden;box-shadow:0 12px 35px rgba(0,0,0,0.1);transition:0.4s;}
        .room-card:hover{transform:translateY(-12px);box-shadow:0 20px 50px rgba(0,0,0,0.15);}
        .room-img{width:100%;height:240px;object-fit:cover;}
        .room-info{padding:25px;}
        .room-type{font-size:24px;font-weight:bold;color:#003580;margin-bottom:8px;}
        .room-price{font-size:28px;font-weight:bold;color:#e74c3c;margin-bottom:15px;}
        .book-btn{display:block;padding:14px;background:#003580;color:white;text-align:center;text-decoration:none;font-weight:bold;border-radius:10px;font-size:16px;transition:0.3s;}
        .book-btn:hover{background:#00275e;}
        .no-rooms{text-align:center;padding:80px 20px;color:#666;font-size:22px;background:white;border-radius:16px;box-shadow:0 10px 30px rgba(0,0,0,0.08);}
        .back-home{display:block;width:280px;margin:40px auto;padding:16px;background:#feba02;color:#003580;text-align:center;text-decoration:none;font-weight:bold;border-radius:12px;font-size:18px;}
        .back-home:hover{background:#e6a800;}
    </style>
</head>
<body>

<header>
    <div class="logo">Booking</div>
    <div class="user-info">
        <% if(session.getAttribute("user")!=null) { %>
            Welcome, <b><%= session.getAttribute("user") %></b>
            <a href="myBookings.jsp">My Bookings</a>
            <a href="logout.jsp">Logout</a>
        <% } else { %>
            <a href="login.jsp">Sign In</a>
            <a href="register.jsp">Register</a>
        <% } %>
    </div>
</header>

<div class="container">
    <%
    int hotelId = Integer.parseInt(request.getParameter("hotel_id"));
    String checkin = request.getParameter("checkin");
    String checkout = request.getParameter("checkout");

    // Fetch hotel name for the title
    String hotelName = "";
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");
        PreparedStatement psHotel = con.prepareStatement("SELECT name FROM hotels WHERE id = ?");
        psHotel.setInt(1, hotelId);
        ResultSet rsHotel = psHotel.executeQuery();
        if (rsHotel.next()) {
            hotelName = rsHotel.getString("name");
        }
    } catch (Exception e) {
        out.print("<div class='no-rooms'>Error fetching hotel name: " + e.getMessage() + "</div>");
    }
    %>

    <h1 class="page-title"><%= hotelName %> Details</h1>
    <p class="search-info">
        <%= checkin %> to <%= checkout %>
    </p>

    <div class="rooms-grid">
        <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");
            PreparedStatement ps = con.prepareStatement("SELECT * FROM rooms WHERE hotel_id = ? AND available = true");
            ps.setInt(1, hotelId);
            ResultSet rs = ps.executeQuery();

            boolean found = false;
            while (rs.next()) {
                found = true;
                int roomId = rs.getInt("id");
                String roomType = rs.getString("type");
                double price = rs.getDouble("price");

                out.print("<div class='room-card'>");
                out.print("<img src='https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800' class='room-img' alt='" + roomType + "'>");
                out.print("<div class='room-info'>");
                out.print("<div class='room-type'>" + roomType + "</div>");
                out.print("<div class='room-price'>₹" + String.format("%.0f", price) + " <small style='color:#666'>/ night</small></div>");
                out.print("<a href='bookingForm.jsp?room_id=" + roomId + "&checkin=" + checkin + "&checkout=" + checkout + 
                          "&hotel_id=" + hotelId + "' class='book-btn'>Book Now</a>");
                out.print("</div></div>");
            }

            if (!found) {
                out.print("<div class='no-rooms'>No available rooms at " + hotelName + " for these dates.</div>");
            }

            con.close();
        } catch (Exception e) {
            out.print("<div class='no-rooms'>Error: " + e.getMessage() + "</div>");
        }
        %>
    </div>

    <a href="searchResults.jsp?location=<%= request.getParameter("location") %>&checkin=<%= checkin %>&checkout=<%= checkout %>" class="back-home">← Back to Search Results</a>
</div>

</body>
</html>