<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@ page import="java.sql.*" %>
<%
int id = Integer.parseInt(request.getParameter("id"));
try {
  Class.forName("com.mysql.jdbc.Driver");
  Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hotel_booking", "root", "hello123");
  PreparedStatement ps = con.prepareStatement("DELETE FROM rooms WHERE id = ?");
  ps.setInt(1, id);
  ps.executeUpdate();
  response.sendRedirect("adminDashboard.jsp");
  con.close();
} catch (Exception e) {
  out.println(e);
}
%>