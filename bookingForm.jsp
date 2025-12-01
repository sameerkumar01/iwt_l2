<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
String redirect = "bookingForm.jsp?room_id=" + request.getParameter("room_id") + "&checkin=" + request.getParameter("checkin") + "&checkout=" + request.getParameter("checkout");
if (session.getAttribute("user") == null) {
  response.sendRedirect("login.jsp?redirect=" + redirect);
}
%>
<!DOCTYPE html>
<html>
<head>
<title>Booking Form</title>
<link rel="stylesheet" href="css/style.css">
</head>
<body>
<form action="payment.jsp" method="post">
  <input type="hidden" name="room_id" value="<%= request.getParameter("room_id") %>">
  <input type="hidden" name="checkin" value="<%= request.getParameter("checkin") %>">
  <input type="hidden" name="checkout" value="<%= request.getParameter("checkout") %>">
  Name: <input type="text" name="name"><br>
  Email: <input type="text" name="email"><br>
  <input type="submit" value="Proceed to Payment">
</form>
</body>
</html>