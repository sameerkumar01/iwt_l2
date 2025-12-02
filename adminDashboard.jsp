<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("index.jsp");
    return;
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard • Booking</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5f7fa; color:#333;}

        /* Top Blue Bar - Same as index.jsp */
        header{
            background:#003580; color:white; padding:20px 40px; display:flex; justify-content:space-between; align-items:center;
        }
        .logo{font-size:28px; font-weight:bold;}
        .user-info a{color:white; margin-left:25px; text-decoration:none; font-weight:500;}
        .user-info a:hover{text-decoration:underline;}

        .container{
            max-width:1300px; margin:40px auto; padding:0 20px;
        }
        h2{
            text-align:center; font-size:36px; color:#003580; margin:40px 0 20px;
        }
        .actions{
            text-align:center; margin-bottom:40px;
        }
        .btn{
            display:inline-block; padding:14px 28px; margin:0 10px; border-radius:10px; text-decoration:none;
            font-weight:bold; font-size:16px; transition:0.3s;
        }
        .add{background:#27ae60; color:white;}
        .add:hover{background:#219a52;}
        .home{background:#feba02; color:#003580;}
        .home:hover{background:#e6a800;}

        /* Cards & Tables */
        .card{
            background:white; border-radius:16px; padding:30px; margin-bottom:40px;
            box-shadow:0 10px 30px rgba(0,0,0,0.08);
        }
        .card h3{
            font-size:24px; color:#003580; margin-bottom:20px; border-bottom:2px solid #feba02; padding-bottom:10px;
        }
        table{
            width:100%; border-collapse:collapse; margin-top:15px;
        }
        th{
            background:#003580; color:white; padding:16px; text-align:left;
        }
        td{
            padding:14px; border-bottom:1px solid #eee;
        }
        tr:hover{background:#f8fdff;}
        tr:nth-child(even){background:#f9f9f9;}

        .status-available{color:#27ae60; font-weight:bold;}
        .status-booked{color:#e74c3c; font-weight:bold;}
        .delete-btn{
            background:#e74c3c; color:white; padding:8px 16px; border-radius:8px; text-decoration:none; font-size:14px;
        }
        .delete-btn:hover{background:#c0392b;}

        .past-card{background:#fff8e1; border-left:6px solid #ff8f00;}
        .no-data{
            text-align:center; color:#666; font-size:18px; padding:40px; background:#f9f9f9; border-radius:12px;
        }
    </style>
</head>
<body>

<header>
    <div class="logo">Booking Admin</div>
    <div class="user-info">
        Welcome, <b>Admin</b>
        <a href="index.jsp">Back to Home</a>
        <a href="logout.jsp">Logout</a>
    </div>
</header>

<div class="container">
    <h2>Admin Dashboard</h2>

    <div class="actions">
        <a href="addHotel.jsp" class="btn add">Add New Hotel</a>
        <a href="addRoom.jsp" class="btn add">Add New Room</a>
        <a href="index.jsp" class="btn home">View Site</a>
    </div>

    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");

        // Active Bookings
        out.print("<div class='card'>");
        out.print("<h3>Current Active Bookings</h3>");
        PreparedStatement psActive = con.prepareStatement(
            "SELECT b.id, u.username, b.name AS guest, b.email, h.name AS hotel, h.location, r.type AS room, r.price, b.check_in, b.check_out "+
            "FROM bookings b JOIN users u ON b.user_id = u.id "+
            "JOIN rooms r ON b.room_id = r.id JOIN hotels h ON r.hotel_id = h.id "+
            "WHERE b.status = 'confirmed' AND b.check_out >= CURDATE() ORDER BY b.check_in DESC");
        ResultSet rsActive = psActive.executeQuery();

        if (!rsActive.next()) {
            out.print("<div class='no-data'>No active bookings right now.</div>");
        } else {
            out.print("<table><tr><th>ID</th><th>User</th><th>Guest</th><th>Hotel</th><th>Location</th><th>Room</th><th>Price</th><th>Check-in</th><th>Check-out</th></tr>");
            do {
                out.print("<tr>");
                out.print("<td>" + rsActive.getInt("id") + "</td>");
                out.print("<td>" + rsActive.getString("username") + "</td>");
                out.print("<td><b>" + rsActive.getString("guest") + "</b><br><small>" + rsActive.getString("email") + "</small></td>");
                out.print("<td>" + rsActive.getString("hotel") + "</td>");
                out.print("<td>" + rsActive.getString("location") + "</td>");
                out.print("<td>" + rsActive.getString("room") + "</td>");
                out.print("<td>₹" + rsActive.getDouble("price") + "</td>");
                out.print("<td>" + rsActive.getDate("check_in") + "</td>");
                out.print("<td>" + rsActive.getDate("check_out") + "</td>");
                out.print("</tr>");
            } while (rsActive.next());
            out.print("</table>");
        }
        out.print("</div>");

        // Past Guests
        out.print("<div class='card past-card'>");
        out.print("<h3>Past Guests (Cancelled / Checked Out)</h3>");
        PreparedStatement psPast = con.prepareStatement(
            "SELECT b.name AS guest, b.email, h.name AS hotel, r.type AS room, b.check_out, b.status, "+
            "CASE WHEN b.status='cancelled' THEN 'Cancelled by User' ELSE 'Checked Out' END AS reason "+
            "FROM bookings b JOIN rooms r ON b.room_id = r.id JOIN hotels h ON r.hotel_id = h.id "+
            "WHERE b.status='cancelled' OR b.check_out < CURDATE() ORDER BY b.check_out DESC");
        ResultSet rsPast = psPast.executeQuery();

        if (!rsPast.next()) {
            out.print("<div class='no-data'>No past guests yet.</div>");
        } else {
            out.print("<table><tr><th>Guest Name</th><th>Email</th><th>Hotel & Room</th><th>Check-out</th><th>Reason</th></tr>");
            do {
                out.print("<tr>");
                out.print("<td><b>" + rsPast.getString("guest") + "</b></td>");
                out.print("<td>" + rsPast.getString("email") + "</td>");
                out.print("<td>" + rsPast.getString("hotel") + " — " + rsPast.getString("room") + "</td>");
                out.print("<td>" + rsPast.getDate("check_out") + "</td>");
                out.print("<td style='color:#e74c3c;font-weight:bold'>" + rsPast.getString("reason") + "</td>");
                out.print("</tr>");
            } while (rsPast.next());
            out.print("</table>");
        }
        out.print("</div>");

        // Hotels List
        out.print("<div class='card'>");
        out.print("<h3>Hotels List <a href='addHotel.jsp' class='btn add' style='float:right;font-size:14px;padding:10px 20px;'>+ Add Hotel</a></h3><div style='clear:both;'></div>");
        PreparedStatement psHotels = con.prepareStatement("SELECT * FROM hotels ORDER BY name");
        ResultSet rsHotels = psHotels.executeQuery();
        while (rsHotels.next()) {
            out.print("<p style='padding:15px;background:#f8f9fa;margin:10px 0;border-radius:10px;'>");
            out.print("<b>" + rsHotels.getString("name") + "</b> — " + rsHotels.getString("location") + " ");
            out.print("<a href='deleteHotel.jsp?id=" + rsHotels.getInt("id") + "' class='delete-btn' onclick='return confirm(\"Delete this hotel permanently?\")'>Delete</a>");
            out.print("</p>");
        }
        out.print("</div>");

        // Rooms List
        out.print("<div class='card'>");
        out.print("<h3>Rooms List <a href='addRoom.jsp' class='btn add' style='float:right;font-size:14px;padding:10px 20px;'>+ Add Room</a></h3><div style='clear:both;'></div>");
        PreparedStatement psRooms = con.prepareStatement(
            "SELECT r.id, r.type, r.price, r.available, h.name AS hotel_name FROM rooms r JOIN hotels h ON r.hotel_id = h.id ORDER BY h.name");
        ResultSet rsRooms = psRooms.executeQuery();
        out.print("<table><tr><th>ID</th><th>Hotel</th><th>Room Type</th><th>Price</th><th>Status</th><th>Action</th></tr>");
        while (rsRooms.next()) {
            String status = rsRooms.getBoolean("available") ? 
                "<span class='status-available'>Available</span>" : 
                "<span class='status-booked'>Booked</span>";
            out.print("<tr>");
            out.print("<td>" + rsRooms.getInt("id") + "</td>");
            out.print("<td>" + rsRooms.getString("hotel_name") + "</td>");
            out.print("<td>" + rsRooms.getString("type") + "</td>");
            out.print("<td>₹" + rsRooms.getDouble("price") + "</td>");
            out.print("<td>" + status + "</td>");
            out.print("<td><a href='deleteRoom.jsp?id=" + rsRooms.getInt("id") + "' class='delete-btn' onclick='return confirm(\"Delete this room?\")'>Delete</a></td>");
            out.print("</tr>");
        }
        out.print("</table></div>");

        con.close();
    } catch (Exception e) {
        out.print("<div class='card' style='background:#ffebee;color:#c62828;padding:30px;text-align:center;'>");
        out.print("<h3>Database Error</h3><p>" + e.getMessage() + "</p></div>");
    }
    %>

</div>
</body>
</html>