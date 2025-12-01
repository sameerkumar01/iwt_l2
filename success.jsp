<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String roomId   = request.getParameter("room_id");
    String checkin  = request.getParameter("checkin");
    String checkout = request.getParameter("checkout");
    String name     = request.getParameter("name");
    String email    = request.getParameter("email");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");

        // Get user_id
        String username = (String) session.getAttribute("user");
        PreparedStatement psUser = con.prepareStatement("SELECT id FROM users WHERE username=?");
        psUser.setString(1, username);
        ResultSet rsUser = psUser.executeQuery();
        int userId = 1;
        if (rsUser.next()) userId = rsUser.getInt("id");

        // INSERT booking — fixed: name, email (was name twice before)
        PreparedStatement ps = con.prepareStatement(
            "INSERT INTO bookings (user_id, room_id, check_in, check_out, name, email, status) VALUES (?, ?, ?, ?, ?, ?, 'booked')");
        ps.setInt(1, userId);
        ps.setInt(2, Integer.parseInt(roomId));
        ps.setDate(3, java.sql.Date.valueOf(checkin));
        ps.setDate(4, java.sql.Date.valueOf(checkout));
        ps.setString(5, name);
        ps.setString(6, email);   // ← this was wrong before
        ps.executeUpdate();

        // Mark room unavailable
        PreparedStatement psRoom = con.prepareStatement("UPDATE rooms SET available = false WHERE id = ?");
        psRoom.setInt(1, Integer.parseInt(roomId));
        psRoom.executeUpdate();

        con.close();
    } catch (Exception e) {
        out.print("<h3 style='color:red'>Booking failed: " + e.getMessage() + "</h3>");
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Booking Success</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<div class="container">
    <h2 style="color:green;">Booking Successful!</h2>
    <p>Thank you <b><%= request.getParameter("name") %></b>, your room has been confirmed.</p>
    <a href="index.jsp">Back to Home</a> |
    <a href="myBookings.jsp">View My Bookings</a>
</div>
</body>
</html>