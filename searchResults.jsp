<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<title>Search Results</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<h2>Hotels in <%= request.getParameter("location") %></h2>
<%
String location = request.getParameter("location");
try {
  Class.forName("com.mysql.jdbc.Driver");
  Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
  PreparedStatement ps = con.prepareStatement("SELECT * FROM hotels WHERE location LIKE ?");
  ps.setString(1, "%" + location + "%");
  ResultSet rs = ps.executeQuery();
  while (rs.next()) {
    out.println("<p><a href='hotelDetails.jsp?hotel_id=" + rs.getInt("id") + "&checkin=" + request.getParameter("checkin") + "&checkout=" + request.getParameter("checkout") + "'>" + rs.getString("name") + "</a></p>");
  }
  con.close();
} catch (Exception e) {
  out.println(e);
}
%>
</body>
</html>