<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<title>Payment</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<form action="success.jsp" method="post">
  <input type="hidden" name="room_id" value="<%= request.getParameter("room_id") %>">
  <input type="hidden" name="checkin" value="<%= request.getParameter("checkin") %>">
  <input type="hidden" name="checkout" value="<%= request.getParameter("checkout") %>">
  <input type="hidden" name="name" value="<%= request.getParameter("name") %>">
  <input type="hidden" name="email" value="<%= request.getParameter("email") %>">
  Card Number (dummy): <input type="text"><br>
  <input type="submit" value="Pay">
</form>
</body>
</html>