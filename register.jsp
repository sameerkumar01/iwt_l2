<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%
if ("POST".equals(request.getMethod())) {
  String username = request.getParameter("username");
  String password = request.getParameter("password");
  try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
    PreparedStatement ps = con.prepareStatement("INSERT INTO users (username, password, role) VALUES (?, ?, 'user')");
    ps.setString(1, username);
    ps.setString(2, password);
    ps.executeUpdate();
    response.sendRedirect("login.jsp");
    con.close();
  } catch (Exception e) {
    out.println(e);
  }
}
%>
<!DOCTYPE html>
<html>
<head>
<title>Register</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<form method="post">
  Username: <input type="text" name="username"><br>
  Password: <input type="password" name="password"><br>
  <input type="submit" value="Register">
</form>
</body>
</html>