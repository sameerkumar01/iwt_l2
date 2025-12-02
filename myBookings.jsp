<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
if (session.getAttribute("user") == null) {
    response.sendRedirect("login.jsp");
    return;
}

// ====== CANCEL BOOKING (GET method) ======
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
    } catch (Exception e) {
        // Silent fail (user already sees success message)
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings • LuxStay</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Segoe UI',sans-serif;}
        body{background:#f5f7fa; color:#333;}

        /* Same Header as Index & Admin */
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
            text-align:center; font-size:36px; color:#003580; margin:20px 0 40px;
        }

        .success{
            background:#d4edda; color:#155724; padding:20px; border-radius:12px; text-align:center;
            font-weight:bold; font-size:18px; margin:20px auto; max-width:800px;
            box-shadow:0 5px 15px rgba(0,0,0,0.1);
        }

        .card{
            background:white; border-radius:16px; padding:30px; margin-bottom:40px;
            box-shadow:0 10px 30px rgba(0,0,0,0.08); overflow:hidden;
        }
        .card h3{
            font-size:24px; color:#003580; margin-bottom:20px; border-bottom:2px solid #feba02; padding-bottom:10px;
        }

        table{
            width:100%; border-collapse:collapse;
        }
        th{
            background:#003580; color:white; padding:18px; text-align:center; font-size:16px;
        }
        td{
            padding:18px; text-align:center; border-bottom:1px solid #eee;
        }
        tr:hover{background:#f8fdff;}
        tr:nth-child(even){background:#f9f9f9;}

        .status-confirmed{color:#27ae60; font-weight:bold;}
        .status-cancelled{color:#e74c3c; font-weight:bold;}

        .cancel-btn{
            background:#e74c3c; color:white; padding:12px 24px; border-radius:10px;
            text-decoration:none; font-weight:bold; font-size:15px; transition:0.3s;
        }
        .cancel-btn:hover{background:#c0392b; transform:scale(1.05);}

        .no-bookings{
            text-align:center; padding:60px; color:#666; font-size:20px; background:#f9f9f9; border-radius:16px;
        }

        .back-home{
            display:block; width:250px; margin:40px auto; padding:16px; background:#feba02; color:#003580;
            text-align:center; text-decoration:none; font-weight:bold; border-radius:12px; font-size:18px;
        }
        .back-home:hover{background:#e6a800;}
    </style>
</head>
<body>

<header>
    <div class="logo">LuxStay</div>
    <div class="user-info">
        Welcome, <b><%= session.getAttribute("user") %></b>
        <a href="index.jsp">Home</a>
        <a href="logout.jsp">Logout</a>
    </div>
</header>

<div class="container">
    <h2>My Bookings</h2>

    <%-- Success Message --%>
    <% if (cancel != null) { %>
        <div class="success">
            Booking cancelled successfully! Your room is now available again.
        </div>
    <% } %>

    <div class="card">
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
                    out.print("<div class='no-bookings'>You have no bookings yet.<br><br>");
                    out.print("<a href='index.jsp' class='back-home'>Book Your First Stay</a></div>");
                } else {
                    out.print("<table>");
                    out.print("<tr><th>Hotel</th><th>Room Type</th><th>Check-in</th><th>Check-out</th><th>Price/Night</th><th>Status</th><th>Action</th></tr>");

                    do {
                        int bookingId = rs.getInt("id");
                        String status = rs.getString("status");

                        out.print("<tr>");
                        out.print("<td><b>" + rs.getString("hotel") + "</b></td>");
                        out.print("<td>" + rs.getString("room_type") + "</td>");
                        out.print("<td>" + rs.getDate("check_in") + "</td>");
                        out.print("<td>" + rs.getDate("check_out") + "</td>");
                        out.print("<td><b>₹" + rs.getDouble("price") + "</b></td>");
                        out.print("<td class='status-" + status + "'>" + status.toUpperCase() + "</td>");
                        out.print("<td>");

                        if ("confirmed".equals(status)) {
                            out.print("<a href='myBookings.jsp?cancel=" + bookingId + "' class='cancel-btn' ");
                            out.print("onclick=\"return confirm('Are you sure you want to cancel this booking?')\">");
                            out.print("Cancel Booking</a>");
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
            out.print("<div style='background:#ffebee;color:#c62828;padding:30px;text-align:center;border-radius:12px;'>");
            out.print("Error loading bookings: " + e.getMessage() + "</div>");
        }
        %>
    </div>

    <a href="index.jsp" class="back-home">Back to Home</a>
</div>

</body>
</html>