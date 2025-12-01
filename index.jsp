<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Hotel Booking - Home</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<header>
    <h1>Hotel Booking System</h1>
    <% if(session.getAttribute("user")==null){ %>
        <a href="login.jsp">Login</a> | <a href="register.jsp">Register</a>
    <% } else { %>
        Welcome, <b><%= session.getAttribute("user") %></b>
        <a href="logout.jsp">Logout</a>
        <% if("user".equals(session.getAttribute("role"))){ %>
            <a href="myBookings.jsp">My Bookings</a>
        <% } else if("admin".equals(session.getAttribute("role"))){ %>
            <a href="adminDashboard.jsp">Admin Dashboard</a>
        <% } %>
    <% } %>
</header>

<div class="container">
    <h2>Search Hotels</h2>
    <form action="searchResults.jsp" method="get">
        <input type="text" name="location" placeholder="Enter city (e.g. Delhi, Mumbai)" required><br>
        <input type="date" name="checkin" required><br>
        <input type="date" name="checkout" required><br>
        <input type="submit" value="Search Hotels">
    </form>
</div>
</body>
</html>