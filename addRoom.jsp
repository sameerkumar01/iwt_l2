<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%
if ("POST".equals(request.getMethod())) {
  int hotel_id = Integer.parseInt(request.getParameter("hotel_id"));
  String type = request.getParameter("type");
  double price = Double.parseDouble(request.getParameter("price"));
  try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
    PreparedStatement ps = con.prepareStatement("INSERT INTO rooms (hotel_id, type, price, available) VALUES (?, ?, ?, true)");
    ps.setInt(1, hotel_id);
    ps.setString(2, type);
    ps.setDouble(3, price);
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
<title>Add Room</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<form method="post">
  Hotel: 
  <select name="hotel_id">
  <%
  try {
    Class.forName("com.mysql.jdbc.Driver");
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
    PreparedStatement ps = con.prepareStatement("SELECT * FROM hotels");
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      out.println("<option value='" + rs.getInt("id") + "'>" + rs.getString("name") + "</option>");
    }
    con.close();
  } catch (Exception e) {
    out.println(e);
  }
  %>
  </select><br>
  Type: <input type="text" name="type"><br>
  Price: <input type="text" name="price"><br>
  <input type="submit" value="Add">
</form>
</body>
</html>