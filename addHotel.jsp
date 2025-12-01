<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%
if ("POST".equals(request.getMethod())) {
  String name = request.getParameter("name");
  String location = request.getParameter("location");
  try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
    PreparedStatement ps = con.prepareStatement("INSERT INTO hotels (name, location) VALUES (?, ?)");
    ps.setString(1, name);
    ps.setString(2, location);
    ps.executeUpdate();
    response.sendRedirect("adminDashboard.jsp");
    con.close();
  } catch (Exception e) {
    out.println(e);
  }
}
%>
<!DOCTYPE html>
<html>
<head>
<title>Add Hotel</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<form method="post">
  Name: <input type="text" name="name"><br>
  Location: <input type="text" name="location"><br>
  <input type="submit" value="Add">
</form>
</body>
</html>