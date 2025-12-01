<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if (session.getAttribute("user") == null) {
    response.sendRedirect("login.jsp");
}

// ====== CANCEL BOOKING (GET method – super reliable) ======
String cancel = request.getParameter("cancel");
if (cancel != null && !cancel.isEmpty()) {
    try {
        int bid = Integer.parseInt(cancel);
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");
        
        PreparedStatement ps1 = con.prepareStatement("UPDATE bookings SET status='cancelled' WHERE id=? AND status='confirmed'");
        ps1.setInt(1, bid);
        ps1.executeUpdate();
        
        PreparedStatement ps2 = con.prepareStatement("UPDATE rooms r JOIN bookings b ON r.id=b.room_id SET r.available=1 WHERE b.id=?");
        ps2.setInt(1, bid);
        ps2.executeUpdate();
        
        con.close();
    } catch (Exception e) {}
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>My Bookings</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        table { width:100%; border-collapse:collapse; margin:20px 0; }
        th, td { border:1px solid #ccc; padding:12px; text-align:center; }
        th { background:#2c3e50; color:white; }
        .cancel-btn {
            background:#e74c3c; color:white; padding:10px 20px; border-radius:6px;
            text-decoration:none; font-weight:bold; display:inline-block;
        }
        .cancel-btn:hover { background:#c0392b; }
        .success { background:#d4edda; color:#155724; padding:15px; border-radius:8px; margin:15px 0; font-weight:bold; }
    </style>
</head>
<body>
<div class="container">
    <h2>My Bookings</h2>

    <%-- Show success message after cancel --%>
    <% if (cancel != null) { %>
        <div class="success">Booking cancelled successfully!</div>
    <% } %>

    <%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking","root","hello123");

        String username = (String) session.getAttribute("user");
        PreparedStatement psUser = con.prepareStatement("SELECT id FROM users WHERE username=?");
        psUser.setString(1, username);
        ResultSet rsUser = psUser.executeQuery();

        if (rsUser.next()) {
            int userId = rsUser.getInt("id");

            PreparedStatement ps = con.prepareStatement(
                "SELECT b.id, b.check_in, b.check_out, b.status, h.name AS hotel, r.type AS room_type, r.price "+
                "FROM bookings b "+
                "JOIN rooms r ON b.room_id=r.id "+
                "JOIN hotels h ON r.hotel_id=h.id "+
                "WHERE b.user_id=? ORDER BY b.check_in DESC");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (!rs.next()) {
                out.print("<p>No bookings found.</p>");
            } else {
                out.print("<table>");
                out.print("<tr><th>Hotel</th><th>Room</th><th>Check-in</th><th>Check-out</th><th>Price</th><th>Status</th><th>Action</th></tr>");

                do {
                    int bookingId = rs.getInt("id");
                    String status = rs.getString("status");

                    out.print("<tr>");
                    out.print("<td><b>" + rs.getString("hotel") + "</b></td>");
                    out.print("<td>" + rs.getString("room_type") + "</td>");
                    out.print("<td>" + rs.getDate("check_in") + "</td>");
                    out.print("<td>" + rs.getDate("check_out") + "</td>");
                    out.print("<td>₹" + rs.getDouble("price") + "</td>");
                    out.print("<td><b style='color:" + ("confirmed".equals(status) ? "green" : "red") + "'>" + 
                              status.toUpperCase() + "</b></td>");
                    out.print("<td>");

                    // CORRECTED LINE – this was the bug
                    if ("confirmed".equals(status)) {
                        out.print("<a href='myBookings.jsp?cancel=" + bookingId + "' class='cancel-btn' " +
                                  " onclick=\"return confirm('Are you sure you want to cancel this booking?')\">Cancel Booking</a>");
                    } else {
                        out.print("—");
                    }

                    out.print("</td></tr>");
                } while (rs.next());
                out.print("</table>");
            }
        }
        con.close();
    } catch (Exception e) {
        out.print("<p style='color:red'>Error: " + e.getMessage() + "</p>");
    }
    %>

    <br><br>
    <a href="index.jsp">Back to Home</a>
</div>
</body>
</html>