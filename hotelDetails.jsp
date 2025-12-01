<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Hotel Details</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<%
int hotel_id = Integer.parseInt(request.getParameter("hotel_id"));
try {
  Class.forName("com.mysql.jdbc.Driver");
  Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
  PreparedStatement ps = con.prepareStatement("SELECT * FROM rooms WHERE hotel_id = ? AND available = true");
  ps.setInt(1, hotel_id);
  ResultSet rs = ps.executeQuery();
  while (rs.next()) {
    out.println("<p>Room: " + rs.getString("type") + " Price: $" + rs.getDouble("price") + " <a href='bookingForm.jsp?room_id=" + rs.getInt("id") + "&checkin=" + request.getParameter("checkin") + "&checkout=" + request.getParameter("checkout") + "'>Book</a></p>");
  }
  con.close();
} catch (Exception e) {
  out.println(e);
}
%>
</body>
</html>