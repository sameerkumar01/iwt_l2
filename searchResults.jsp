<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hotels in <%= request.getParameter("location") %> • Booking</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5f7fa;color:#333;}
        header{background:#003580;color:white;padding:20px 40px;display:flex;justify-content:space-between;align-items:center;}
        .logo{font-size:28px;font-weight:bold;}
        .user-info a{color:white;margin-left:25px;text-decoration:none;font-weight:500;}
        .user-info a:hover{text-decoration:underline;}
        .container{max-width:1300px;margin:40px auto;padding:0 20px;}
        .page-title{text-align:center;font-size:36px;color:#003580;margin:20px 0 10px;}
        .search-info{text-align:center;color:#666;font-size:18px;margin-bottom:40px;}
        .hotels-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(360px,1fr));gap:30px;}
        .hotel-card{background:white;border-radius:16px;overflow:hidden;box-shadow:0 12px 35px rgba(0,0,0,0.1);transition:0.4s;display:flex;flex-direction:column;}
        .hotel-card:hover{transform:translateY(-12px);box-shadow:0 20px 50px rgba(0,0,0,0.15);}
        .hotel-img{width:100%;height:240px;object-fit:cover;}
        .hotel-info{padding:25px;flex-grow:1;display:flex;flex-direction:column;}
        .hotel-name{font-size:24px;font-weight:bold;color:#003580;margin-bottom:8px;}
        .hotel-location{color:#666;margin-bottom:15px;font-size:15px;}
        .rating{background:#feba02;color:#003580;padding:6px 12px;border-radius:8px;display:inline-block;font-weight:bold;font-size:14px;margin-bottom:15px;}
        .price{font-size:28px;font-weight:bold;color:#e74c3c;margin-top:auto;}
        .view-btn{display:block;margin-top:15px;padding:14px;background:#003580;color:white;text-align:center;text-decoration:none;font-weight:bold;border-radius:10px;font-size:16px;transition:0.3s;}
        .view-btn:hover{background:#00275e;}
        .no-results{text-align:center;padding:80px 20px;color:#666;font-size:22px;background:white;border-radius:16px;box-shadow:0 10px 30px rgba(0,0,0,0.08);}
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
    <h1 class="page-title">Hotels in <%= request.getParameter("location") %></h1>
    <p class="search-info">
        <%= request.getParameter("checkin") %> to <%= request.getParameter("checkout") %>
    </p>

    <div class="hotels-grid">
        <%
        String location = request.getParameter("location");
        String checkin = request.getParameter("checkin");
        String checkout = request.getParameter("checkout");

        if (location == null || location.trim().isEmpty()) {
            out.print("<div class='no-results'>Please enter a location to search.</div>");
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");

                // This query gets hotels + the CHEAPEST available room price
                PreparedStatement ps = con.prepareStatement(
                    "SELECT h.id, h.name, h.location, " +
                    "COALESCE(MIN(r.price), 0) AS min_price " +
                    "FROM hotels h " +
                    "LEFT JOIN rooms r ON h.id = r.hotel_id AND r.available = 1 " +
                    "WHERE h.location LIKE ? " +
                    "GROUP BY h.id, h.name, h.location " +
                    "HAVING min_price > 0 " +  // Only show hotels that have at least 1 available room
                    "ORDER BY h.name"
                );
                ps.setString(1, "%" + location + "%");
                ResultSet rs = ps.executeQuery();

                boolean found = false;
                while (rs.next()) {
                    found = true;
                    int hotelId = rs.getInt("id");
                    String hotelName = rs.getString("name");
                    String hotelLocation = rs.getString("location");
                    double minPrice = rs.getDouble("min_price");

                    out.print("<div class='hotel-card'>");
                    out.print("<img src='https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800' class='hotel-img' alt='" + hotelName + "'>");
                    out.print("<div class='hotel-info'>");
                    out.print("<div class='hotel-name'>" + hotelName + "</div>");
                    out.print("<div class='hotel-location'>" + hotelLocation + "</div>");
                    out.print("<div class='rating'>4.8 ★ Excellent</div>");
                    out.print("<div class='price'>From ₹" + String.format("%.0f", minPrice) + " <small style='color:#666'>/ night</small></div>");
                    out.print("<a href='hotelDetails.jsp?hotel_id=" + hotelId + 
                              "&checkin=" + checkin + "&checkout=" + checkout + 
                              "' class='view-btn'>View Rooms & Book</a>");
                    out.print("</div></div>");
                }

                if (!found) {
                    out.print("<div class='no-results'>");
                    out.print("<h3>No available hotels in \"" + location + "\"</h3>");
                    out.print("<p>Try searching: Mumbai, Delhi, Bangalore, Goa, Bhubaneshwar</p>");
                    out.print("</div>");
                }

                con.close();
            } catch (Exception e) {
                out.print("<div class='no-results'>Database Error: " + e.getMessage() + "</div>");
            }
        }
        %>
    </div>

    <a href="index.jsp" class="back-home">Back to Search</a>
</div>

</body>
</html>