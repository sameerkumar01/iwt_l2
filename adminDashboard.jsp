<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("index.jsp");
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body { font-family: Arial, sans-serif; background: #f9f9f9; margin:0; padding:20px; }
        .container { max-width: 1200px; margin: auto; background: white; padding: 25px; border-radius: 10px; box-shadow: 0 0 15px rgba(0,0,0,0.1); }
        h2, h3 { color: #2c3e50; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background: #34495e; color: white; }
        tr:nth-child(even) { background: #f2f2f2; }
        a { color: #3498db; text-decoration: none; font-weight: bold; }
        a:hover { text-decoration: underline; }
        .btn { padding: 8px 12px; border-radius: 5px; color: white; text-decoration: none; font-size: 14px; }
        .add { background: #27ae60; }
        .delete { background: #e74c3c; }
        .section { margin-bottom: 50px; }
        .past { background: #fff3cd; border-left: 6px solid #f39c12; padding: 15px; }
    </style>
</head>
<body>
<div class="container">
    <h2>Admin Dashboard</h2>
    <p>
        <a href="addHotel.jsp" class="btn add">Add Hotel</a> |
        <a href="addRoom.jsp" class="btn add">Add Room</a> |
        <a href="index.jsp">Home</a>
    </p>

    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");

        // ========== CURRENT / ACTIVE BOOKINGS ==========
        out.print("<div class='section'>");
        out.print("<h3>Current Active Bookings</h3>");
        PreparedStatement psActive = con.prepareStatement(
            "SELECT b.id, u.username, b.name AS guest, b.email, h.name AS hotel, h.location, r.type AS room, r.price, b.check_in, b.check_out "+
            "FROM bookings b "+
            "JOIN users u ON b.user_id = u.id "+
            "JOIN rooms r ON b.room_id = r.id "+
            "JOIN hotels h ON r.hotel_id = h.id "+
            "WHERE b.status = 'confirmed' AND b.check_out >= CURDATE() "+
            "ORDER BY b.check_in DESC");
        ResultSet rsActive = psActive.executeQuery();

        if (!rsActive.next()) {
            out.print("<p>No active bookings right now.");
        } else {
            out.print("<table>");
            out.print("<tr>"+
                      "<th>ID</th><th>User</th><th>Guest Name</th><th>Hotel</th><th>Location</th>"+
                      "<th>Room</th><th>Price</th><th>Check-in</th><th>Check-out</th></tr>");
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

        // ========== PAST GUESTS (Cancelled or Checked-out) ==========
        out.print("<div class='section past'>");
        out.print("<h3>Past Guests (Cancelled or Checked Out)</h3>");
        PreparedStatement psPast = con.prepareStatement(
            "SELECT b.name AS guest, b.email, h.name AS hotel, r.type AS room, b.check_out, b.status, "+
            "CASE WHEN b.status='cancelled' THEN 'Cancelled by User' "+
                 "ELSE 'Checked Out' END AS reason "+
            "FROM bookings b "+
            "JOIN rooms r ON b.room_id = r.id "+
            "JOIN hotels h ON r.hotel_id = h.id "+
            "WHERE b.status='cancelled' OR b.check_out < CURDATE() "+
            "ORDER BY b.check_out DESC");
        ResultSet rsPast = psPast.executeQuery();

        if (!rsPast.next()) {
            out.print("<p>No past guests yet.</p>");
        } else {
            out.print("<table>");
            out.print("<tr style='background:#8e44ad;color:white'>"+
                      "<th>Guest Name</th><th>Email</th><th>Hotel & Room</th><th>Check-out Date</th><th>Reason</th></tr>");
            do {
                out.print("<tr>");
                out.print("<td><b>" + rsPast.getString("guest") + "</b></td>");
                out.print("<td>" + rsPast.getString("email") + "</td>");
                out.print("<td>" + rsPast.getString("hotel") + " — " + rsPast.getString("room") + "</td>");
                out.print("<td>" + rsPast.getDate("check_out") + "</td>");
                out.print("<td style='color:red;font-weight:bold'>" + rsPast.getString("reason") + "</td>");
                out.print("</tr>");
            } while (rsPast.next());
            out.print("</table>");
        }
        out.print("</div>");

        // ========== HOTELS LIST ==========
        out.print("<div class='section'>");
        out.print("<h3>Hotels List <a href='addHotel.jsp' class='btn add'>[+ Add Hotel]</a></h3>");
        PreparedStatement psHotels = con.prepareStatement("SELECT * FROM hotels ORDER BY name");
        ResultSet rsHotels = psHotels.executeQuery();
        while (rsHotels.next()) {
            out.print("<p><b>" + rsHotels.getString("name") + "</b> — " + rsHotels.getString("location") +
                      " <a href='deleteHotel.jsp?id=" + rsHotels.getInt("id") + 
                      "' class='btn delete' onclick='return confirm(\"Delete hotel?\")'>Delete</a></p>");
        }
        out.print("</div>");

        // ========== ROOMS LIST ==========
        out.print("<div class='section'>");
        out.print("<h3>Rooms List <a href='addRoom.jsp' class='btn add'>[+ Add Room]</a></h3>");
        PreparedStatement psRooms = con.prepareStatement(
            "SELECT r.id, r.type, r.price, r.available, h.name AS hotel_name "+
            "FROM rooms r JOIN hotels h ON r.hotel_id = h.id ORDER BY h.name");
        ResultSet rsRooms = psRooms.executeQuery();
        out.print("<table>");
        out.print("<tr><th>ID</th><th>Hotel</th><th>Room Type</th><th>Price</th><th>Status</th><th>Action</th></tr>");
        while (rsRooms.next()) {
            String status = rsRooms.getBoolean("available") ? "<span style='color:green'>Available</span>" : "<span style='color:red'>Booked</span>";
            out.print("<tr>");
            out.print("<td>" + rsRooms.getInt("id") + "</td>");
            out.print("<td>" + rsRooms.getString("hotel_name") + "</td>");
            out.print("<td>" + rsRooms.getString("type") + "</td>");
            out.print("<td>₹" + rsRooms.getDouble("price") + "</td>");
            out.print("<td>" + status + "</td>");
            out.print("<td><a href='deleteRoom.jsp?id=" + rsRooms.getInt("id") + 
                      "' class='btn delete' onclick='return confirm(\"Delete room?\")'>Delete</a></td>");
            out.print("</tr>");
        }
        out.print("</table>");
        out.print("</div>");

        con.close();
    } catch (Exception e) {
        out.print("<p style='color:red;font-size:18px'>Database Error: " + e.getMessage() + "</p>");
    }
    %>
</div>
</body>
</html>